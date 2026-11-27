# Uji RLS otomatis untuk KosFinder.
# Kredensial dibaca dari proses `flutter run` yang sedang aktif dan TIDAK ditulis ke file ini.
$ErrorActionPreference = 'Stop'

function Get-SupabaseConfig {
  $proc = Get-CimInstance Win32_Process |
    Where-Object { $_.CommandLine -match 'SUPABASE_URL=' } |
    Select-Object -First 1
  if (-not $proc) {
    throw 'Tidak ada proses flutter run dengan --dart-define SUPABASE_URL. Jalankan aplikasi dulu.'
  }
  $cl = $proc.CommandLine
  $urlMatch = [regex]::Match($cl, 'SUPABASE_URL=([^ ]+)')
  $keyMatch = [regex]::Match($cl, 'SUPABASE_ANON_KEY=([^ ]+)')
  if (-not $urlMatch.Success -or -not $keyMatch.Success) {
    throw 'Gagal membaca SUPABASE_URL / SUPABASE_ANON_KEY dari proses.'
  }
  return @{
    Url   = $urlMatch.Groups[1].Value.TrimEnd('"')
    Anon  = $keyMatch.Groups[1].Value.TrimEnd('"')
  }
}

function Invoke-Api {
  param(
    [string]$Uri,
    [string]$Method,
    [hashtable]$Headers,
    [string]$Body
  )
  $args = @{
    Uri             = $Uri
    Method          = $Method
    Headers         = $Headers
    UseBasicParsing = $true
    TimeoutSec      = 60
  }
  if ($Body) { $args.Body = $Body }

  try {
    $r = Invoke-WebRequest @args
    return [pscustomobject]@{ Status = [int]$r.StatusCode; Text = $r.Content }
  } catch {
    $resp = $_.Exception.Response
    if ($resp) {
      $text = ''
      try {
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $text = $reader.ReadToEnd()
      } catch {
        $text = $_.Exception.Message
      }
      return [pscustomobject]@{ Status = [int]$resp.StatusCode; Text = $text }
    }
    return [pscustomobject]@{ Status = 0; Text = $_.Exception.Message }
  }
}

function Redact([string]$text) {
  if (-not $text) { return '' }
  $text = $text.Replace($script:Anon, '<ANON_KEY>')
  $text = $text.Replace($script:TokenA, '<TOKEN_A>')
  $text = $text.Replace($script:TokenB, '<TOKEN_B>')
  $text = $text.Replace($script:PasswordA, '<PASSWORD>')
  $text = $text.Replace($script:PasswordB, '<PASSWORD>')
  return $text
}

function Sign-In([string]$email, [string]$password) {
  $body = @{ email = $email; password = $password } | ConvertTo-Json
  $r = Invoke-Api -Uri "$($script:Url)/auth/v1/token?grant_type=password" `
    -Method Post `
    -Headers @{ apikey = $script:Anon; 'Content-Type' = 'application/json' } `
    -Body $body
  if ($r.Status -ne 200) {
    throw "Login gagal [$($r.Status)]: $(Redact $r.Text)"
  }
  $data = ConvertFrom-Json -InputObject $r.Text
  if (-not $data.access_token) {
    throw "Login tidak menghasilkan access_token: $(Redact $r.Text)"
  }
  return @{
    Token  = $data.access_token
    UserId = $data.user.id
    Email  = $data.user.email
  }
}

$cfg = Get-SupabaseConfig
$script:Url  = $cfg.Url
$script:Anon = $cfg.Anon

$suffix = Get-Date -Format 'yyyyMMddHHmmss'
$script:PasswordA = 'RlsTestA!12345'
$script:PasswordB = 'RlsTestB!12345'
$emailA = "rls_a_$suffix@example.com"
$emailB = "rls_b_$suffix@example.com"

$lines = @()
$lines += ' KosFinder - Uji RLS otomatis'
$lines += " Waktu     : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += " Project   : $(([uri]$script:Url).Host)"
$lines += " Akun A    : $emailA"
$lines += " Akun B    : $emailB"
$lines += ''

try {
  # 1. Daftar dua akun uji.
  foreach ($pair in @(@($emailA, $script:PasswordA), @($emailB, $script:PasswordB))) {
    $body = @{ email = $pair[0]; password = $pair[1] } | ConvertTo-Json
    $r = Invoke-Api -Uri "$($script:Url)/auth/v1/signup" `
      -Method Post `
      -Headers @{ apikey = $script:Anon; 'Content-Type' = 'application/json' } `
      -Body $body
    if ($r.Status -ge 300 -and $r.Text -notmatch 'already registered|user_already_exists') {
      throw "Signup gagal [$($r.Status)]: $(Redact $r.Text)"
    }
  }
  $lines += ' Signup A/B : OK'

  # 2. Login sebagai A dan B.
  $a = Sign-In $emailA $script:PasswordA
  $script:TokenA = $a.Token
  $b = Sign-In $emailB $script:PasswordB
  $script:TokenB = $b.Token
  $lines += ' Login A/B  : OK'

  # 3. A menambah satu kos uji.
  $insertBody = @{
    owner_id     = $a.UserId
    nama         = "RLS Test $suffix"
    area         = 'Singaraja'
    harga        = 100000
    fasilitas    = 'Data uji otomatis'
    jumlah_kamar = 1
  } | ConvertTo-Json

  $ins = Invoke-Api -Uri "$($script:Url)/rest/v1/kos" `
    -Method Post `
    -Headers @{
      apikey        = $script:Anon
      Authorization = "Bearer $($script:TokenA)"
      'Content-Type' = 'application/json'
      Prefer         = 'return=representation'
    } `
    -Body $insertBody
  if ($ins.Status -ge 300) {
    throw "Insert kos gagal [$($ins.Status)]: $(Redact $ins.Text)"
  }
  $rows = ConvertFrom-Json -InputObject $ins.Text
  $kosId = $rows[0].id
  if (-not $kosId) { throw 'Insert kos tidak mengembalikan id.' }
  $lines += " Insert A   : OK (id=$kosId)"

  $readHeaders = @{ apikey = $script:Anon; Authorization = "Bearer $($script:TokenA)" }

  # 4. B mencoba mengubah kos A.
  $patch = Invoke-Api -Uri "$($script:Url)/rest/v1/kos?id=eq.$kosId" `
    -Method Patch `
    -Headers @{
      apikey        = $script:Anon
      Authorization = "Bearer $($script:TokenB)"
      'Content-Type' = 'application/json'
    } `
    -Body (@{ jumlah_kamar = 99 } | ConvertTo-Json)
  $check1 = Invoke-Api -Uri "$($script:Url)/rest/v1/kos?id=eq.$kosId" -Method Get -Headers $readHeaders
  $after = (ConvertFrom-Json -InputObject $check1.Text)[0].jumlah_kamar
  $us08 = if ($after -eq 1) { 'PASS' } else { 'FAIL' }
  $lines += " US08-AC2   : $us08 - PATCH B status=$($patch.Status), jumlah_kamar setelahnya=$after (harus 1)"

  # 5. B mencoba menghapus kos A.
  $del = Invoke-Api -Uri "$($script:Url)/rest/v1/kos?id=eq.$kosId" `
    -Method Delete `
    -Headers @{ apikey = $script:Anon; Authorization = "Bearer $($script:TokenB)" }
  $check2 = Invoke-Api -Uri "$($script:Url)/rest/v1/kos?id=eq.$kosId" -Method Get -Headers $readHeaders
  $stillExists = @(ConvertFrom-Json -InputObject $check2.Text).Count -gt 0
  $us09 = if ($stillExists) { 'PASS' } else { 'FAIL' }
  $lines += " US09-AC2   : $us09 - DELETE B status=$($del.Status), kos masih ada=$stillExists"

  # 6. Bersihkan kos uji. Akun uji tidak bisa dihapus tanpa service_role.
  $cleanup = Invoke-Api -Uri "$($script:Url)/rest/v1/kos?id=eq.$kosId" `
    -Method Delete `
    -Headers @{ apikey = $script:Anon; Authorization = "Bearer $($script:TokenA)" }
  $lines += " Cleanup    : kos uji dihapus status=$($cleanup.Status)"
  $lines += ' Catatan    : akun uji A/B tetap ada di Authentication; hapus manual di Dashboard bila perlu.'

  if ($us08 -eq 'FAIL' -or $us09 -eq 'FAIL') {
    $lines += ''
    $lines += ' Detail PATCH : ' + (Redact $patch.Text)
    $lines += ' Detail DELETE: ' + (Redact $del.Text)
  }
} catch {
  $lines += ''
  $lines += ' ERROR: ' + (Redact $_.Exception.Message)
}

$lines += ''
$text = $lines -join [Environment]::NewLine
$out = Join-Path $PSScriptRoot 'rls_test_result.txt'
Set-Content -LiteralPath $out -Value $text -Encoding UTF8
$text
