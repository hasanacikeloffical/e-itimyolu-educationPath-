<?php
/* =============================================================
 *  HOME.PHP  —  Anasayfa Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Mevcut veriyi çek
$query = $pdo->query("SELECT * FROM hometbl WHERE HomeId = 1");
$data  = $query->fetch();

// Form gönderildiğinde
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title     = trim($_POST['HomeTitle']    ?? '');
    $subtitle  = trim($_POST['HomeSubTitle'] ?? '');
    $imageName = $_POST['old_image']         ?? 'default.jpg';

    // Yeni görsel yüklendiyse işle
    if (isset($_FILES['HomeImagefile']) && $_FILES['HomeImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        $extension = pathinfo($_FILES['HomeImagefile']['name'], PATHINFO_EXTENSION);
        $imageName = time() . '_' . uniqid() . '.' . $extension;
        move_uploaded_file($_FILES['HomeImagefile']['tmp_name'], $uploadDir . $imageName);
    }

    // Kayıt var mı kontrol et
    $check = $pdo->query("SELECT HomeId FROM hometbl WHERE HomeId = 1")->fetch();

    if ($check) {
        $stmt = $pdo->prepare("UPDATE hometbl SET HomeTitle = ?, HomeSubTitle = ?, HomeImagefile = ? WHERE HomeId = 1");
        $stmt->execute([$title, $subtitle, $imageName]);
    } else {
        $stmt = $pdo->prepare("INSERT INTO hometbl (HomeId, HomeTitle, HomeSubTitle, HomeImagefile) VALUES (1, ?, ?, ?)");
        $stmt->execute([$title, $subtitle, $imageName]);
    }

    header('Location: Home.php?success=1');
    exit;
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content d-flex flex-column" id="Home">
    <div class="p-4">

        <?php if (isset($_GET['success'])): ?>
            <div class="alert alert-success border-0 shadow-sm rounded-3">
                ✅ Başarıyla kaydedildi ve veritabanı güncellendi!
            </div>
        <?php endif; ?>

        <form action="Home.php" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="old_image"
                   value="<?= htmlspecialchars($data['HomeImagefile'] ?? 'default.jpg') ?>">

            <div class="card border-0 shadow-sm rounded-4 mt-3">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3 px-4">
                    <div class="rounded-circle d-flex align-items-center justify-content-center shadow-sm"
                         style="width:45px; height:45px; background:#f0f7ff; font-size:20px">🏠</div>
                    <div>
                        <h6 class="mb-0 fw-bold text-dark">Anasayfa Yönetimi</h6>
                        <p class="mb-0 text-muted" style="font-size:13px">
                            Veritabanı tablosu: <b>hometbl</b>
                        </p>
                    </div>
                </div>

                <div class="card-body p-4">
                    <div class="row g-4">

                        <div class="col-md-6">
                            <label class="form-label fw-semibold small">Home Title</label>
                            <input type="text"
                                   class="form-control bg-light"
                                   name="HomeTitle"
                                   value="<?= htmlspecialchars($data['HomeTitle'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold small">Home SubTitle</label>
                            <input type="text"
                                   class="form-control bg-light"
                                   name="HomeSubTitle"
                                   value="<?= htmlspecialchars($data['HomeSubTitle'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-12 mt-4">
                            <div class="p-3 border rounded-3 bg-light">
                                <label class="form-label fw-semibold small d-block">Arkaplan Görseli</label>
                                <div class="d-flex align-items-center gap-3">
                                    <img src="../uploads/<?= htmlspecialchars($data['HomeImagefile'] ?? 'default.jpg') ?>"
                                         class="rounded shadow-sm border"
                                         style="width:100px; height:60px; object-fit:cover"
                                         onerror="this.src='https://via.placeholder.com/100x60?text=Yok'">
                                    <input type="file"
                                           class="form-control form-control-sm"
                                           name="HomeImagefile"
                                           accept="image/*">
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-white border-top p-3 d-flex justify-content-end">
                    <button type="submit" class="btn btn-primary px-5 shadow-sm fw-bold">KAYDET</button>
                </div>

            </div>
        </form>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  ABOUT.PHP  —  Hakkımızda Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Mevcut veriyi çek
$query = $pdo->query("SELECT * FROM abouttbl WHERE AboutId = 1");
$data  = $query->fetch();

// Veri yoksa varsayılan değerleri ata
if (!$data) {
    $data = [
        'AboutTitle'       => '',
        'AboutDescription' => '',
        'AboutBirthday'    => '',
        'profileImagefile' => 'default.jpg',
    ];
}

// Form gönderildiğinde
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = trim($_POST['AboutTitle']       ?? '');
    $desc  = trim($_POST['AboutDescription'] ?? '');
    $birth = trim($_POST['AboutBirthday']    ?? '');
    $image = $_POST['old_image']             ?? 'default.jpg';

    // Görsel yükleme
    if (isset($_FILES['profileImagefile']) && $_FILES['profileImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $ext              = strtolower(pathinfo($_FILES['profileImagefile']['name'], PATHINFO_EXTENSION));
        $allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

        if (in_array($ext, $allowedExtensions)) {
            $newImageName = 'about_' . time() . '.' . $ext;

            if (move_uploaded_file($_FILES['profileImagefile']['tmp_name'], $uploadDir . $newImageName)) {
                // Eski görseli sil (varsayılan değilse)
                if ($image !== 'default.jpg' && file_exists($uploadDir . $image)) {
                    unlink($uploadDir . $image);
                }
                $image = $newImageName;
            }
        }
    }

    // Upsert (varsa güncelle, yoksa ekle)
    $sql = "INSERT INTO abouttbl (AboutId, AboutTitle, AboutDescription, AboutBirthday, profileImagefile)
            VALUES (1, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                AboutTitle        = VALUES(AboutTitle),
                AboutDescription  = VALUES(AboutDescription),
                AboutBirthday     = VALUES(AboutBirthday),
                profileImagefile  = VALUES(profileImagefile)";

    $pdo->prepare($sql)->execute([$title, $desc, $birth, $image]);

    header('Location: about.php?status=ok');
    exit;
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4" id="About">
    <div id="sec-about">
        <form action="About.php" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="old_image"
                   value="<?= htmlspecialchars($data['profileImagefile']) ?>">

            <div class="card border-0 shadow-sm rounded-4">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center shadow-sm"
                         style="width:40px; height:40px; background:#eff6ff; font-size:18px">🏢</div>
                    <div>
                        <p class="mb-0 fw-bold text-dark">Hakkımızda Yönetimi</p>
                        <p class="mb-0 text-muted" style="font-size:13px">
                            Veritabanı tablosu: <b>abouttbl</b>
                        </p>
                    </div>
                </div>

                <div class="row g-3 align-items-stretch mt-3">

                    <!-- Sol: Başlık ve Doğum Tarihi -->
                    <div class="col-md-2 d-flex flex-column gap-3">
                        <div>
                            <label class="form-label fw-bold small text-secondary">Başlık (Ünvan)</label>
                            <input type="text"
                                   name="AboutTitle"
                                   class="form-control"
                                   value="<?= htmlspecialchars($data['AboutTitle']) ?>"
                                   placeholder="Örn: Yazılım Geliştirici">
                        </div>
                        <div>
                            <label class="form-label fw-bold small text-secondary">Doğum Tarihi</label>
                            <input type="date"
                                   name="AboutBirthday"
                                   class="form-control"
                                   value="<?= htmlspecialchars($data['AboutBirthday']) ?>">
                        </div>
                    </div>

                    <!-- Orta: Profil Resmi -->
                    <div class="col-md-5">
                        <label class="form-label fw-bold small text-secondary">Profil Resmi</label>
                        <div class="d-flex align-items-center gap-3 p-3 border rounded-3 bg-light-subtle h-100">
                            <img src="uploads/<?= htmlspecialchars($data['profileImagefile']) ?>"
                                 class="rounded-circle border shadow-sm"
                                 style="width:70px; height:70px; object-fit:cover">
                            <div class="flex-grow-1">
                                <input type="file"
                                       name="profileImagefile"
                                       class="form-control form-control-sm"
                                       accept="image/*">
                                <div class="form-text text-xs">
                                    Mevcut dosya: <?= htmlspecialchars($data['profileImagefile']) ?>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Sağ: Açıklama -->
                    <div class="col-md-5">
                        <label class="form-label fw-bold small text-secondary">Hakkımda Açıklaması</label>
                        <textarea name="AboutDescription"
                                  class="form-control h-100"
                                  rows="4"
                                  style="min-height:125px"
                                  placeholder="Biyografinizi yazın..."><?= htmlspecialchars($data['AboutDescription']) ?></textarea>
                    </div>

                </div>

                <div class="card-footer bg-white border-top d-flex justify-content-end gap-2 py-3 px-4 mt-5">
                    <button type="reset" class="btn btn-sm btn-outline-secondary px-3">
                        <i class="bi bi-x-circle me-1"></i>Temizle
                    </button>
                    <button type="submit" class="btn btn-sm btn-primary px-4 shadow-sm fw-bold">
                        <i class="bi bi-check-circle me-1"></i>Kaydet
                    </button>
                </div>

            </div>
        </form>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  TEAMS.PHP  —  Ekip Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM teamstbl WHERE TeamId = ?")->execute([(int)$_GET['delete']]);
    header('Location: teams.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name     = trim($_POST['TeamName']        ?? '');
    $surname  = trim($_POST['TeamSurname']     ?? '');
    $job      = trim($_POST['TeamJobName']     ?? '');
    $desc     = trim($_POST['TeamDescription'] ?? '');
    $id       = $_POST['TeamId']               ?? null;
    $imageName = $_POST['current_image']       ?? 'default-team.jpg';

    if (isset($_FILES['TeamImagefile']) && $_FILES['TeamImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        $extension = pathinfo($_FILES['TeamImagefile']['name'], PATHINFO_EXTENSION);
        $imageName = 'team_' . time() . '.' . $extension;
        move_uploaded_file($_FILES['TeamImagefile']['tmp_name'], $uploadDir . $imageName);
    }

    if ($id) {
        $sql = "UPDATE teamstbl SET TeamName=?, TeamSurname=?, TeamJobName=?, TeamDescription=?, TeamImagefile=? WHERE TeamId=?";
        $pdo->prepare($sql)->execute([$name, $surname, $job, $desc, $imageName, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO teamstbl (TeamName, TeamSurname, TeamJobName, TeamDescription, TeamImagefile) VALUES (?, ?, ?, ?, ?)";
        $pdo->prepare($sql)->execute([$name, $surname, $job, $desc, $imageName]);
        $status = 'added';
    }

    header("Location: teams.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$teams    = $pdo->query("SELECT * FROM teamstbl ORDER BY TeamId DESC")->fetchAll();
$editData = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM teamstbl WHERE TeamId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div id="sec-team" class="mb-5">
        <form action="teams.php" method="POST" enctype="multipart/form-data">

            <?php if ($editData): ?>
                <input type="hidden" name="TeamId"        value="<?= $editData['TeamId'] ?>">
                <input type="hidden" name="current_image" value="<?= $editData['TeamImagefile'] ?>">
            <?php endif; ?>

            <div class="card border-0 shadow-sm rounded-4">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center shadow-sm"
                         style="width:36px; height:36px; background:#ecfdf5; font-size:16px">👥</div>
                    <div>
                        <p class="mb-0 fw-bold text-dark">Ekip Yönetimi</p>
                        <p class="mb-0 text-muted" style="font-size:13px">
                            Veritabanı tablosu: <b>teamstbl</b>
                        </p>
                    </div>
                </div>

                <div class="card-body p-4">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-secondary">Ad</label>
                            <input type="text" name="TeamName" class="form-control"
                                   placeholder="Ad"
                                   value="<?= htmlspecialchars($editData['TeamName'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-secondary">Soyad</label>
                            <input type="text" name="TeamSurname" class="form-control"
                                   placeholder="Soyad"
                                   value="<?= htmlspecialchars($editData['TeamSurname'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-secondary">Unvan</label>
                            <input type="text" name="TeamJobName" class="form-control"
                                   placeholder="Frontend Developer"
                                   value="<?= htmlspecialchars($editData['TeamJobName'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary">Profil Fotoğrafı</label>
                            <input type="file" name="TeamImagefile" class="form-control form-control-sm">
                        </div>

                        <div class="col-12">
                            <label class="form-label small fw-bold text-secondary">Biyografi / Açıklama</label>
                            <textarea name="TeamDescription" class="form-control" rows="2"
                                      placeholder="Kısa biyografi..."><?= htmlspecialchars($editData['TeamDescription'] ?? '') ?></textarea>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-white border-top d-flex justify-content-end gap-2 py-3 px-4">
                    <?php if ($editData): ?>
                        <a href="teams.php" class="btn btn-sm btn-outline-secondary px-3">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4 fw-bold">
                        <i class="bi bi-check-circle me-1"></i>
                        <?= $editData ? 'Güncelle' : 'Ekle' ?>
                    </button>
                </div>

            </div>
        </form>
    </div>

    <!-- Ekip Listesi -->
    <div class="card border rounded-3 shadow-sm mt-4">
        <div class="card-header bg-white py-3 border-bottom text-dark fw-bold">
            Mevcut Ekip Listesi
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0 text-center">
                <thead class="bg-light">
                    <tr style="font-size:11px">
                        <th class="py-3">ÜYE</th>
                        <th class="py-3">UNVAN</th>
                        <th class="py-3">AÇIKLAMA</th>
                        <th class="py-3">PROFİL RESMİ</th>
                        <th class="text-center pe-4 py-3">İŞLEMLER</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($teams as $row): ?>
                    <tr>
                        <td class="ps-4">
                            <div class="d-flex align-items-center gap-3">
                                <img src="../uploads/<?= htmlspecialchars($row['TeamImagefile'] ?? 'default-team.jpg') ?>"
                                     class="rounded-circle border"
                                     style="width:40px; height:40px; object-fit:cover">
                                <div class="fw-semibold text-dark">
                                    <?= htmlspecialchars($row['TeamName'] . ' ' . $row['TeamSurname']) ?>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge rounded-pill bg-primary bg-opacity-10 text-primary fw-medium">
                                <?= htmlspecialchars($row['TeamJobName']) ?>
                            </span>
                        </td>
                        <td class="text-muted small">
                            <?= mb_strimwidth(htmlspecialchars($row['TeamDescription']), 0, 60, '...') ?>
                        </td>
                        <td class="text-muted small">
                            <?= mb_strimwidth(htmlspecialchars($row['TeamImagefile']), 0, 60, '...') ?>
                        </td>
                        <td class="text-center pe-4">
                            <div class="btn-group shadow-sm rounded-2">
                                <a href="teams.php?edit=<?= $row['TeamId'] ?>"
                                   class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                <a href="teams.php?delete=<?= $row['TeamId'] ?>"
                                   class="btn btn-sm btn-danger py-0 px-2"
                                   onclick="return confirm('Bu üyeyi silmek istediğinize emin misiniz?')">Sil</a>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  CERTIFICATES.PHP  —  Sertifika Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM certificatetbl WHERE CertificateId = ?")->execute([(int)$_GET['delete']]);
    header('Location: certificates.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title     = trim($_POST['CertificateTitle'] ?? '');
    $time      = trim($_POST['CertificateTime']  ?? '');
    $id        = $_POST['CertificateId']          ?? null;
    $imageName = $_POST['current_image']           ?? 'no-certificate.jpg';

    if (isset($_FILES['CertificateImagefile']) && $_FILES['CertificateImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        $extension = pathinfo($_FILES['CertificateImagefile']['name'], PATHINFO_EXTENSION);
        $imageName = 'cert_' . time() . '.' . $extension;
        move_uploaded_file($_FILES['CertificateImagefile']['tmp_name'], $uploadDir . $imageName);
    }

    if ($id) {
        $sql = "UPDATE certificatetbl SET CertificateTitle=?, CertificateTime=?, CertificateImagefile=? WHERE CertificateId=?";
        $pdo->prepare($sql)->execute([$title, $time, $imageName, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO certificatetbl (CertificateTitle, CertificateTime, CertificateImagefile) VALUES (?, ?, ?)";
        $pdo->prepare($sql)->execute([$title, $time, $imageName]);
        $status = 'added';
    }

    header("Location: certificates.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$certificates = $pdo->query("SELECT * FROM certificatetbl ORDER BY CertificateId DESC")->fetchAll();
$editData     = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM certificatetbl WHERE CertificateId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div id="sec-certificate" class="mb-5">
        <form action="certificates.php" method="POST" enctype="multipart/form-data">

            <?php if ($editData): ?>
                <input type="hidden" name="CertificateId"    value="<?= $editData['CertificateId'] ?>">
                <input type="hidden" name="current_image"    value="<?= $editData['CertificateImagefile'] ?>">
            <?php endif; ?>

            <div class="card border rounded-3 shadow-sm">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3">
                    <div class="rounded-2 d-flex align-items-center justify-content-center"
                         style="width:36px; height:36px; background:#fff7ed; font-size:16px">🏆</div>
                    <h6 class="mb-0 fw-semibold" style="font-size:14px">
                        <?= $editData ? 'Sertifikayı Düzenle' : 'Yeni Sertifika Ekle' ?>
                    </h6>
                </div>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-3">
                            <label class="form-label fw-medium" style="font-size:12px">Sertifika Adı</label>
                            <input type="text" name="CertificateTitle" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['CertificateTitle'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-medium" style="font-size:12px">Veriliş Tarihi</label>
                            <input type="date" name="CertificateTime" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['CertificateTime'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-medium" style="font-size:12px">Belge Resmi</label>
                            <input type="file" name="CertificateImagefile" class="form-control form-control-sm">
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-white border-top d-flex justify-content-end gap-2 py-3">
                    <?php if ($editData): ?>
                        <a href="certificates.php" class="btn btn-sm btn-light">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary">
                        <i class="bi bi-check-circle me-1"></i>
                        <?= $editData ? 'Güncellemeyi Kaydet' : 'Kaydet' ?>
                    </button>
                </div>

            </div>
        </form>
    </div>

    <!-- Sertifika Listesi -->
    <div class="card border rounded-3 shadow-sm mt-4">
        <div class="bg-light p-3 border-bottom rounded-top">
            <h1 class="h6 m-0 fw-bold text-secondary">
                <i class="bi bi-award-fill me-2"></i>Sertifika Liste Tablosu
            </h1>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 text-center">
                    <thead class="table-light">
                        <tr style="font-size:12px">
                            <th>ID</th>
                            <th>RESİM</th>
                            <th>SERTİFİKA ADI</th>
                            <th>VERİLİŞ TARİHİ</th>
                            <th>İŞLEMLER</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($certificates as $row): ?>
                        <tr>
                            <td class="small fw-bold text-muted"><?= $row['CertificateId'] ?></td>
                            <td>
                                <img src="../uploads/<?= htmlspecialchars($row['CertificateImagefile'] ?: 'no-certificate.jpg') ?>"
                                     class="rounded border"
                                     style="width:50px; height:35px; object-fit:cover">
                            </td>
                            <td class="fw-medium text-dark"><?= htmlspecialchars($row['CertificateTitle']) ?></td>
                            <td class="small"><?= date('d.m.Y', strtotime($row['CertificateTime'])) ?></td>
                            <td>
                                <a href="certificates.php?edit=<?= $row['CertificateId'] ?>"
                                   class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                <a href="certificates.php?delete=<?= $row['CertificateId'] ?>"
                                   class="btn btn-sm btn-danger py-0 px-2"
                                   onclick="return confirm('Bu sertifikayı silmek istediğinize emin misiniz?')">Sil</a>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($certificates)): ?>
                            <tr>
                                <td colspan="5" class="py-4 text-muted">
                                    Henüz kayıtlı bir sertifika bulunamadı.
                                </td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  CAREERS.PHP  —  Kariyer Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM careertbl WHERE CereerId = ?")->execute([(int)$_GET['delete']]);
    header('Location: careers.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title   = trim($_POST['CereerTitle']       ?? '');
    $company = trim($_POST['CereerCompanyName'] ?? '');
    $time    = trim($_POST['CereerTime']        ?? '');
    $desc    = trim($_POST['CereerDescription'] ?? '');
    $id      = $_POST['CereerId']               ?? null;

    if ($id) {
        $sql = "UPDATE careertbl SET CereerTitle=?, CereerCompanyName=?, CereerTime=?, CereerDescription=? WHERE CereerId=?";
        $pdo->prepare($sql)->execute([$title, $company, $time, $desc, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO careertbl (CereerTitle, CereerCompanyName, CereerTime, CereerDescription) VALUES (?, ?, ?, ?)";
        $pdo->prepare($sql)->execute([$title, $company, $time, $desc]);
        $status = 'added';
    }

    header("Location: careers.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$careers  = $pdo->query("SELECT * FROM careertbl ORDER BY CereerId DESC")->fetchAll();
$editData = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM careertbl WHERE CereerId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div id="sec-career" class="mb-5">
        <form action="careers.php" method="POST">

            <?php if ($editData): ?>
                <input type="hidden" name="CereerId" value="<?= $editData['CereerId'] ?>">
            <?php endif; ?>

            <div class="card border rounded-3 shadow-sm">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3">
                    <div class="rounded-2 d-flex align-items-center justify-content-center"
                         style="width:36px; height:36px; background:#f5f3ff; font-size:16px">💼</div>
                    <h6 class="mb-0 fw-semibold" style="font-size:14px">
                        <?= $editData ? 'Kariyer Kaydını Düzenle' : 'Yeni Kariyer Ekle' ?>
                    </h6>
                </div>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="form-label fw-medium" style="font-size:12px">Pozisyon / Başlık</label>
                            <input type="text" name="CereerTitle" class="form-control form-control-sm"
                                   placeholder="Yazılım Geliştirici"
                                   value="<?= htmlspecialchars($editData['CereerTitle'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label fw-medium" style="font-size:12px">Şirket / Kurum Adı</label>
                            <input type="text" name="CereerCompanyName" class="form-control form-control-sm"
                                   placeholder="Teknoloji A.Ş."
                                   value="<?= htmlspecialchars($editData['CereerCompanyName'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label fw-medium" style="font-size:12px">Çalışma Tarihi / Aralığı</label>
                            <input type="text" name="CereerTime" class="form-control form-control-sm"
                                   placeholder="Örn: 2020 - 2023"
                                   value="<?= htmlspecialchars($editData['CereerTime'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-medium" style="font-size:12px">İş Tanımı ve Sorumluluklar</label>
                            <textarea name="CereerDescription" class="form-control form-control-sm" rows="1"
                                      placeholder="Pozisyon tanımı..."><?= htmlspecialchars($editData['CereerDescription'] ?? '') ?></textarea>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-white border-top d-flex justify-content-end gap-2 py-3">
                    <?php if ($editData): ?>
                        <a href="careers.php" class="btn btn-sm btn-light border">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary">
                        <i class="bi bi-check-circle me-1"></i>
                        <?= $editData ? 'Güncellemeyi Kaydet' : 'Kaydet' ?>
                    </button>
                </div>

            </div>
        </form>
    </div>

    <!-- Kariyer Listesi -->
    <div class="card border rounded-3 shadow-sm">
        <div class="bg-light p-3 border-bottom rounded-top">
            <h1 class="h6 m-0 fw-bold text-secondary">
                <i class="bi bi-briefcase-fill me-2"></i>Kariyer Liste Tablosu
            </h1>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 text-center">
                    <thead class="table-light">
                        <tr style="font-size:12px">
                            <th>ID</th>
                            <th>POZİSYON</th>
                            <th>ŞİRKET</th>
                            <th>TARİH</th>
                            <th>İŞ TANIMI</th>
                            <th>İŞLEMLER</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($careers as $row): ?>
                        <tr>
                            <td class="small fw-bold text-muted"><?= $row['CereerId'] ?></td>
                            <td class="fw-bold text-dark"><?= htmlspecialchars($row['CereerTitle']) ?></td>
                            <td>
                                <span class="badge bg-secondary bg-opacity-10 text-secondary">
                                    <?= htmlspecialchars($row['CereerCompanyName']) ?>
                                </span>
                            </td>
                            <td class="small text-muted"><?= htmlspecialchars($row['CereerTime']) ?></td>
                            <td class="small text-muted">
                                <?= mb_strimwidth(htmlspecialchars($row['CereerDescription']), 0, 40, '...') ?>
                            </td>
                            <td>
                                <div class="btn-group">
                                    <a href="careers.php?edit=<?= $row['CereerId'] ?>"
                                       class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                    <a href="careers.php?delete=<?= $row['CereerId'] ?>"
                                       class="btn btn-sm btn-danger py-0 px-2"
                                       onclick="return confirm('Bu kariyer kaydını silmek istediğinize emin misiniz?')">Sil</a>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($careers)): ?>
                            <tr>
                                <td colspan="6" class="py-4 text-muted">
                                    Henüz kayıtlı kariyer bilgisi bulunamadı.
                                </td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  EDUCATIONS.PHP  —  Eğitim Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM educationtbl WHERE EducationId = ?")->execute([(int)$_GET['delete']]);
    header('Location: educations.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title  = trim($_POST['EducationTitle']      ?? '');
    $time   = trim($_POST['EducationTime']       ?? '');
    $school = trim($_POST['EducationSchoolName'] ?? '');
    $desc   = trim($_POST['EducationDescription'] ?? '');
    $id     = $_POST['EducationId']              ?? null;

    if ($id) {
        $sql = "UPDATE educationtbl SET EducationTitle=?, EducationTime=?, EducationSchoolName=?, EducationDescription=? WHERE EducationId=?";
        $pdo->prepare($sql)->execute([$title, $time, $school, $desc, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO educationtbl (EducationTitle, EducationTime, EducationSchoolName, EducationDescription) VALUES (?, ?, ?, ?)";
        $pdo->prepare($sql)->execute([$title, $time, $school, $desc]);
        $status = 'added';
    }

    header("Location: educations.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$educations = $pdo->query("SELECT * FROM educationtbl ORDER BY EducationId DESC")->fetchAll();
$editData   = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM educationtbl WHERE EducationId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div id="sec-education" class="mb-5">
        <form action="educations.php" method="POST">

            <?php if ($editData): ?>
                <input type="hidden" name="EducationId" value="<?= $editData['EducationId'] ?>">
            <?php endif; ?>

            <div class="card border-0 shadow-sm rounded-4">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center shadow-sm"
                         style="width:36px; height:36px; background:#f0f9ff; font-size:16px">🎓</div>
                    <h6 class="mb-0 fw-bold">
                        <?= $editData ? 'Eğitim Bilgisini Düzenle' : 'Yeni Eğitim Ekle' ?>
                    </h6>
                </div>

                <div class="card-body p-4">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-secondary">Eğitim Başlığı / Bölüm</label>
                            <input type="text" name="EducationTitle" class="form-control"
                                   placeholder="Örn: Bilgisayar Mühendisliği"
                                   value="<?= htmlspecialchars($editData['EducationTitle'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-secondary">Okul Adı</label>
                            <input type="text" name="EducationSchoolName" class="form-control"
                                   placeholder="Örn: İstanbul Üniversitesi"
                                   value="<?= htmlspecialchars($editData['EducationSchoolName'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold text-secondary">Tarih Aralığı</label>
                            <input type="text" name="EducationTime" class="form-control"
                                   placeholder="Örn: 2018 - 2022"
                                   value="<?= htmlspecialchars($editData['EducationTime'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small fw-bold text-secondary">Kısa Açıklama</label>
                            <textarea name="EducationDescription" class="form-control" rows="1"
                                      placeholder="Eğitim hakkında kısa detaylar..."><?= htmlspecialchars($editData['EducationDescription'] ?? '') ?></textarea>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-white border-top d-flex justify-content-end gap-2 py-3 px-4">
                    <?php if ($editData): ?>
                        <a href="educations.php" class="btn btn-sm btn-outline-secondary px-3">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4 fw-bold">
                        <i class="bi bi-check-circle me-1"></i>
                        <?= $editData ? 'Güncellemeyi Kaydet' : 'Ekle' ?>
                    </button>
                </div>

            </div>
        </form>
    </div>

    <!-- Eğitim Listesi -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
        <div class="card-header bg-white py-3 border-bottom">
            <h6 class="mb-0 fw-bold text-dark">Eğitim Veri Listesi</h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-light">
                    <tr style="font-size:11px; text-transform:uppercase; color:#6c757d">
                        <th class="ps-4 py-3">EĞİTİM / OKUL</th>
                        <th class="py-3">TARİH</th>
                        <th class="py-3">AÇIKLAMA</th>
                        <th class="text-center pe-4 py-3">İŞLEMLER</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($educations as $row): ?>
                    <tr>
                        <td class="ps-4">
                            <div class="fw-bold text-dark"><?= htmlspecialchars($row['EducationTitle']) ?></div>
                            <div class="small text-muted"><?= htmlspecialchars($row['EducationSchoolName']) ?></div>
                        </td>
                        <td>
                            <span class="badge rounded-pill bg-info bg-opacity-10 text-info fw-medium">
                                <?= htmlspecialchars($row['EducationTime']) ?>
                            </span>
                        </td>
                        <td class="text-muted small">
                            <?= mb_strimwidth(htmlspecialchars($row['EducationDescription']), 0, 50, '...') ?>
                        </td>
                        <td class="text-center pe-4">
                            <div class="btn-group shadow-sm rounded-2">
                                <a href="educations.php?edit=<?= $row['EducationId'] ?>"
                                   class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                <a href="educations.php?delete=<?= $row['EducationId'] ?>"
                                   class="btn btn-sm btn-danger py-0 px-2"
                                   onclick="return confirm('Bu eğitim bilgisini silmek istediğinize emin misiniz?')">Sil</a>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (empty($educations)): ?>
                        <tr>
                            <td colspan="4" class="text-center py-5 text-muted small">
                                Henüz eğitim bilgisi eklenmemiş.
                            </td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  BLOGS.PHP  —  Blog Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi (PDF dosyasıyla birlikte)
if (isset($_GET['delete'])) {
    $id   = (int)$_GET['delete'];
    $stmt = $pdo->prepare("SELECT Blogfile FROM blogtbl WHERE BlogId = ?");
    $stmt->execute([$id]);
    $oldFile = $stmt->fetchColumn();

    if ($oldFile && file_exists('../uploads/' . $oldFile)) {
        unlink('../uploads/' . $oldFile);
    }

    $pdo->prepare("DELETE FROM blogtbl WHERE BlogId = ?")->execute([$id]);
    header('Location: blogs.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id       = $_POST['BlogId']      ?? null;
    $type     = trim($_POST['Blogtype']    ?? '');
    $time     = trim($_POST['BlogTime']    ?? '');
    $title    = trim($_POST['BlogTitle']   ?? '');
    $subtitle = trim($_POST['BlogSubTitle'] ?? '');
    $blogFile = $_POST['old_file']          ?? null;

    // PDF yükleme
    if (isset($_FILES['Blogfile']) && $_FILES['Blogfile']['error'] === UPLOAD_ERR_OK) {
        $ext = strtolower(pathinfo($_FILES['Blogfile']['name'], PATHINFO_EXTENSION));

        if ($ext === 'pdf') {
            $newName = 'blog_' . time() . '.pdf';
            $target  = '../uploads/' . $newName;

            if (move_uploaded_file($_FILES['Blogfile']['tmp_name'], $target)) {
                // Eski PDF dosyasını sil
                if (!empty($_POST['old_file']) && file_exists('../uploads/' . $_POST['old_file'])) {
                    unlink('../uploads/' . $_POST['old_file']);
                }
                $blogFile = $newName;
            }
        }
    }

    if ($id) {
        $sql = "UPDATE blogtbl SET Blogtype=?, BlogTime=?, BlogTitle=?, BlogSubTitle=?, Blogfile=? WHERE BlogId=?";
        $pdo->prepare($sql)->execute([$type, $time, $title, $subtitle, $blogFile, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO blogtbl (Blogtype, BlogTime, BlogTitle, BlogSubTitle, Blogfile) VALUES (?, ?, ?, ?, ?)";
        $pdo->prepare($sql)->execute([$type, $time, $title, $subtitle, $blogFile]);
        $status = 'added';
    }

    header("Location: blogs.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$blogs    = $pdo->query("SELECT * FROM blogtbl ORDER BY BlogId DESC")->fetchAll();
$editData = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM blogtbl WHERE BlogId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div class="container-fluid">

        <!-- Form -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3">
                <h6 class="mb-0 fw-bold text-dark">
                    <i class="bi bi-journal-text me-2"></i>
                    <?= $editData ? 'Bloğu Düzenle' : 'Yeni Blog Yazısı Ekle' ?>
                </h6>
            </div>
            <form action="" method="POST" enctype="multipart/form-data">
                <?php if ($editData): ?>
                    <input type="hidden" name="BlogId"   value="<?= $editData['BlogId'] ?>">
                    <input type="hidden" name="old_file" value="<?= $editData['Blogfile'] ?>">
                <?php endif; ?>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="form-label small fw-bold">Blog Türü</label>
                            <input type="text" name="Blogtype" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['Blogtype'] ?? '') ?>"
                                   placeholder="Örn: Teknoloji"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold">Yayın Tarihi</label>
                            <input type="date" name="BlogTime" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['BlogTime'] ?? date('Y-m-d')) ?>"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold">Başlık</label>
                            <input type="text" name="BlogTitle" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['BlogTitle'] ?? '') ?>"
                                   placeholder="Yazı Başlığı"
                                   required>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label small fw-bold">PDF Dosyası (Blogfile)</label>
                            <input type="file" name="Blogfile" class="form-control form-control-sm" accept=".pdf">
                            <?php if (!empty($editData['Blogfile'])): ?>
                                <div class="form-text small text-success">
                                    Mevcut: <?= htmlspecialchars($editData['Blogfile']) ?>
                                </div>
                            <?php endif; ?>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label small fw-bold">Alt Başlık / İçerik Özeti</label>
                            <textarea name="BlogSubTitle" class="form-control" rows="1" required><?= htmlspecialchars($editData['BlogSubTitle'] ?? '') ?></textarea>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-light d-flex justify-content-end gap-2">
                    <?php if ($editData): ?>
                        <a href="blogs.php" class="btn btn-sm btn-secondary">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4">
                        <?= $editData ? 'Güncelle' : 'Ekle' ?>
                    </button>
                </div>
            </form>
        </div>

        <!-- Liste -->
        <div class="card shadow-sm border-0">
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr class="small text-uppercase">
                            <th class="ps-3">ID</th>
                            <th>Blog Türü</th>
                            <th>Başlık</th>
                            <th>Dosya</th>
                            <th>Tarih</th>
                            <th class="text-center">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($blogs as $row): ?>
                        <tr>
                            <td class="ps-3 fw-bold"><?= $row['BlogId'] ?></td>
                            <td><span class="badge bg-secondary"><?= htmlspecialchars($row['Blogtype'] ?? '') ?></span></td>
                            <td class="fw-medium"><?= htmlspecialchars($row['BlogTitle'] ?? '') ?></td>
                            <td>
                                <?php if (!empty($row['Blogfile'])): ?>
                                    <a href="../uploads/<?= htmlspecialchars($row['Blogfile']) ?>"
                                       target="_blank" class="text-danger">
                                        <i class="bi bi-file-earmark-pdf"></i> PDF
                                    </a>
                                <?php else: ?>
                                    <span class="text-muted small">Yok</span>
                                <?php endif; ?>
                            </td>
                            <td class="text-muted small">
                                <?= isset($row['BlogTime']) ? date('d.m.Y', strtotime($row['BlogTime'])) : '-' ?>
                            </td>
                            <td class="text-center">
                                <div class="btn-group">
                                    <a href="blogs.php?edit=<?= $row['BlogId'] ?>"
                                       class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                    <a href="blogs.php?delete=<?= $row['BlogId'] ?>"
                                       class="btn btn-sm btn-danger py-0 px-2"
                                       onclick="return confirm('Bu yazıyı ve PDF dosyasını silmek istediğinize emin misiniz?')">Sil</a>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($blogs)): ?>
                            <tr>
                                <td colspan="6" class="text-center py-4 text-muted">
                                    Henüz blog yazısı eklenmemiş.
                                </td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  GALLERY.PHP  —  Galeri Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi (dosyayla birlikte)
if (isset($_GET['delete'])) {
    $id   = (int)$_GET['delete'];
    $stmt = $pdo->prepare("SELECT GalleryImagefile FROM gallerytbl WHERE GalleryId = ?");
    $stmt->execute([$id]);
    $file = $stmt->fetch();

    if ($file) {
        @unlink('../uploads/' . $file['GalleryImagefile']);
        $pdo->prepare("DELETE FROM gallerytbl WHERE GalleryId = ?")->execute([$id]);
    }

    header('Location: gallery.php?status=deleted');
    exit;
}

// Yükleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['GalleryImagefile'])) {
    if ($_FILES['GalleryImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        $extension = pathinfo($_FILES['GalleryImagefile']['name'], PATHINFO_EXTENSION);
        $fileName  = 'gal_' . time() . '_' . rand(100, 999) . '.' . $extension;

        if (move_uploaded_file($_FILES['GalleryImagefile']['tmp_name'], $uploadDir . $fileName)) {
            $pdo->prepare("INSERT INTO gallerytbl (GalleryImagefile) VALUES (?)")->execute([$fileName]);
            header('Location: gallery.php?status=success');
            exit;
        }
    }
}

// Listeleme
$images = $pdo->query("SELECT * FROM gallerytbl ORDER BY GalleryId DESC")->fetchAll();

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div class="container-fluid">

        <!-- Yükleme Formu -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3">
                <h6 class="mb-0 fw-bold text-dark">
                    <i class="bi bi-images me-2"></i>Galeriye Yeni Fotoğraf Ekle
                </h6>
            </div>
            <div class="card-body">
                <form action="" method="POST" enctype="multipart/form-data" class="row g-3 align-items-center">
                    <div class="col-md-9">
                        <input type="file" name="GalleryImagefile" class="form-control" accept="image/*" required>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary w-100">Yükle</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Galeri Kartları -->
        <div class="row row-cols-1 row-cols-md-3 row-cols-lg-4 g-4">
            <?php foreach ($images as $img): ?>
            <div class="col">
                <div class="card h-100 shadow-sm border-0 position-relative gallery-card">
                    <img src="../uploads/<?= htmlspecialchars($img['GalleryImagefile']) ?>"
                         class="card-img-top rounded"
                         style="height:200px; object-fit:cover">
                    <div class="card-body p-2 text-center">
                        <a href="gallery.php?delete=<?= $img['GalleryId'] ?>"
                           class="btn btn-sm btn-danger w-100"
                           onclick="return confirm('Bu görseli kalıcı olarak silmek istediğinize emin misiniz?')">
                            <i class="bi bi-trash me-1"></i>Sil
                        </a>
                    </div>
                    <div class="position-absolute top-0 end-0 p-2">
                        <span class="badge bg-dark opacity-75">#<?= $img['GalleryId'] ?></span>
                    </div>
                </div>
            </div>
            <?php endforeach; ?>

            <?php if (empty($images)): ?>
                <div class="col-12 text-center py-5">
                    <p class="text-muted">Galeride henüz fotoğraf bulunmuyor.</p>
                </div>
            <?php endif; ?>
        </div>

    </div>
</div>

<style>
    .gallery-card:hover { transform: translateY(-5px); transition: 0.3s; }
</style>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  ANNOUNCEMENTS.PHP  —  Duyuru Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM announcementtbl WHERE announcementId = ?")->execute([(int)$_GET['delete']]);
    header('Location: announcements.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id   = $_POST['announcementId']   ?? null;
    $text = trim($_POST['announcementText'] ?? '');
    $date = trim($_POST['announcementDate'] ?? '');

    if ($id) {
        $sql = "UPDATE announcementtbl SET announcementText=?, announcementDate=? WHERE announcementId=?";
        $pdo->prepare($sql)->execute([$text, $date, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO announcementtbl (announcementText, announcementDate) VALUES (?, ?)";
        $pdo->prepare($sql)->execute([$text, $date]);
        $status = 'added';
    }

    header("Location: announcements.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$announcements = $pdo->query("SELECT * FROM announcementtbl ORDER BY announcementDate DESC")->fetchAll();
$editData      = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM announcementtbl WHERE announcementId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div class="container-fluid">

        <!-- Form -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3">
                <h6 class="mb-0 fw-bold text-dark">
                    <i class="bi bi-megaphone me-2"></i>
                    <?= $editData ? 'Duyuruyu Düzenle' : 'Yeni Duyuru Ekle' ?>
                </h6>
            </div>
            <form action="" method="POST">
                <?php if ($editData): ?>
                    <input type="hidden" name="announcementId" value="<?= $editData['announcementId'] ?>">
                <?php endif; ?>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="form-label small fw-bold">Duyuru Tarihi</label>
                            <input type="date" name="announcementDate" class="form-control"
                                   value="<?= htmlspecialchars($editData['announcementDate'] ?? date('Y-m-d')) ?>"
                                   required>
                        </div>

                        <div class="col-md-10">
                            <label class="form-label small fw-bold">Duyuru Metni</label>
                            <textarea name="announcementText" class="form-control" rows="1"
                                      placeholder="Duyuru içeriğini buraya yazın..."
                                      required><?= htmlspecialchars($editData['announcementText'] ?? '') ?></textarea>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-light d-flex justify-content-end gap-2">
                    <?php if ($editData): ?>
                        <a href="announcements.php" class="btn btn-sm btn-secondary">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4">
                        <?= $editData ? 'Güncelle' : 'Kaydet' ?>
                    </button>
                </div>
            </form>
        </div>

        <!-- Liste -->
        <div class="card shadow-sm border-0">
            <div class="card-body">
                <table class="table table-hover align-middle mb-0 text-center">
                    <thead class="table-light">
                        <tr class="small text-center">
                            <th class="ps-3" style="width:50px">ID</th>
                            <th>Tarih</th>
                            <th>Duyuru Mesajı</th>
                            <th class="text-muted">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($announcements as $row): ?>
                        <tr>
                            <td class="ps-3 fw-bold"><?= $row['announcementId'] ?></td>
                            <td class="fw-medium text-dark text-center">
                                <?= date('d.m.Y', strtotime($row['announcementDate'])) ?>
                            </td>
                            <td class="fw-medium text-dark text-center">
                                <?= htmlspecialchars($row['announcementText']) ?>
                            </td>
                            <td class="text-center">
                                <div class="btn-group">
                                    <a href="announcements.php?edit=<?= $row['announcementId'] ?>"
                                       class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                    <a href="announcements.php?delete=<?= $row['announcementId'] ?>"
                                       class="btn btn-sm btn-danger py-0 px-2"
                                       onclick="return confirm('Bu duyuruyu silmek istediğinize emin misiniz?')">Sil</a>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($announcements)): ?>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">
                                    Henüz kayıtlı duyuru bulunmuyor.
                                </td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  PROJECTS.PHP  —  Proje Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi (görsel dosyasıyla birlikte)
if (isset($_GET['delete'])) {
    $id   = (int)$_GET['delete'];
    $stmt = $pdo->prepare("SELECT ProjectImagefile FROM projecttbl WHERE ProjectId = ?");
    $stmt->execute([$id]);
    $project = $stmt->fetch();

    if ($project) {
        if ($project['ProjectImagefile'] !== 'no-image.png'
            && file_exists('../uploads/' . $project['ProjectImagefile'])) {
            unlink('../uploads/' . $project['ProjectImagefile']);
        }
        $pdo->prepare("DELETE FROM projecttbl WHERE ProjectId = ?")->execute([$id]);
    }

    header('Location: projects.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id        = $_POST['ProjectId']     ?? null;
    $status    = trim($_POST['ProjectStatus'] ?? '');
    $imageName = $_POST['current_image'] ?? 'no-image.png';

    if (isset($_FILES['ProjectImagefile']) && $_FILES['ProjectImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        $extension = pathinfo($_FILES['ProjectImagefile']['name'], PATHINFO_EXTENSION);
        $newName   = 'pro_main_' . time() . '.' . $extension;

        if (move_uploaded_file($_FILES['ProjectImagefile']['tmp_name'], $uploadDir . $newName)) {
            if ($imageName !== 'no-image.png' && file_exists($uploadDir . $imageName)) {
                unlink($uploadDir . $imageName);
            }
            $imageName = $newName;
        }
    }

    if ($id) {
        $sql = "UPDATE projecttbl SET ProjectStatus=?, ProjectImagefile=? WHERE ProjectId=?";
        $pdo->prepare($sql)->execute([$status, $imageName, $id]);
        $msg = 'updated';
    } else {
        $sql = "INSERT INTO projecttbl (ProjectStatus, ProjectImagefile) VALUES (?, ?)";
        $pdo->prepare($sql)->execute([$status, $imageName]);
        $msg = 'added';
    }

    header("Location: projects.php?status=$msg");
    exit;
}

// Listeleme ve düzenleme modu
$projects = $pdo->query("SELECT * FROM projecttbl ORDER BY ProjectId DESC")->fetchAll();
$editData = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM projecttbl WHERE ProjectId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div class="container-fluid">

        <!-- Form -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3">
                <h6 class="mb-0 fw-bold text-dark">
                    <i class="bi bi-plus-circle me-2"></i>
                    <?= $editData ? 'Projeyi Güncelle' : 'Yeni Ana Proje Ekle' ?>
                </h6>
            </div>
            <form action="projects.php" method="POST" enctype="multipart/form-data">
                <?php if ($editData): ?>
                    <input type="hidden" name="ProjectId"     value="<?= $editData['ProjectId'] ?>">
                    <input type="hidden" name="current_image" value="<?= $editData['ProjectImagefile'] ?>">
                <?php endif; ?>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Proje Durumu</label>
                            <select name="ProjectStatus" class="form-select form-select-sm" required>
                                <option value="Tamamlanan"
                                    <?= ($editData['ProjectStatus'] ?? '') === 'Tamamlanan' ? 'selected' : '' ?>>
                                    Tamamlanan
                                </option>
                                <option value="Devam Eden"
                                    <?= ($editData['ProjectStatus'] ?? '') === 'Devam Eden' ? 'selected' : '' ?>>
                                    Devam Eden
                                </option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label small fw-bold">Kapak Görseli</label>
                            <input type="file" name="ProjectImagefile" class="form-control form-control-sm">
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-light d-flex justify-content-end gap-2">
                    <?php if ($editData): ?>
                        <a href="projects.php" class="btn btn-sm btn-secondary">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4">
                        <?= $editData ? 'Güncelle' : 'Kaydet' ?>
                    </button>
                </div>
            </form>
        </div>

        <!-- Liste -->
        <div class="card shadow-sm border-0">
            <div class="card-body p-0">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr class="small text-uppercase">
                            <th class="ps-3">ID</th>
                            <th>Görsel</th>
                            <th>Durum</th>
                            <th class="text-center">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($projects as $row): ?>
                        <tr>
                            <td class="ps-3 fw-bold"><?= $row['ProjectId'] ?></td>
                            <td>
                                <img src="../uploads/<?= htmlspecialchars($row['ProjectImagefile'] ?: 'no-image.png') ?>"
                                     class="rounded shadow-sm"
                                     style="width:60px; height:40px; object-fit:cover">
                            </td>
                            <td>
                                <span class="badge <?= $row['ProjectStatus'] === 'Tamamlanan' ? 'bg-success' : 'bg-info text-dark' ?>">
                                    <?= htmlspecialchars($row['ProjectStatus']) ?>
                                </span>
                            </td>
                            <td class="text-center">
                                <div class="btn-group">
                                    <a href="projectdetail.php?ProjectId=<?= $row['ProjectId'] ?>"
                                       class="btn btn-sm btn-outline-primary" title="Detayları Düzenle">
                                        <i class="bi bi-card-list"></i> Detaylar
                                    </a>
                                    <a href="projects.php?edit=<?= $row['ProjectId'] ?>"
                                       class="btn btn-sm btn-outline-warning">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="projects.php?delete=<?= $row['ProjectId'] ?>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Silmek istediğinize emin misiniz?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  REFERENCES.PHP  —  Referans Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM referancetbl WHERE ReferanceId = ?")->execute([(int)$_GET['delete']]);
    header('Location: references.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $company    = trim($_POST['ReferanceCompanyName']    ?? '');
    $subCompany = trim($_POST['ReferanceSubCompanyName'] ?? '');
    $id         = $_POST['ReferanceId']                  ?? null;
    $imageName  = $_POST['current_image']                ?? 'no-logo.png';

    if (isset($_FILES['ReferanceImagefile']) && $_FILES['ReferanceImagefile']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = '../uploads/';
        $extension = pathinfo($_FILES['ReferanceImagefile']['name'], PATHINFO_EXTENSION);
        $imageName = 'ref_' . time() . '.' . $extension;
        move_uploaded_file($_FILES['ReferanceImagefile']['tmp_name'], $uploadDir . $imageName);
    }

    if ($id) {
        $sql = "UPDATE referancetbl SET ReferanceCompanyName=?, ReferanceSubCompanyName=?, ReferanceImagefile=? WHERE ReferanceId=?";
        $pdo->prepare($sql)->execute([$company, $subCompany, $imageName, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO referancetbl (ReferanceCompanyName, ReferanceSubCompanyName, ReferanceImagefile) VALUES (?, ?, ?)";
        $pdo->prepare($sql)->execute([$company, $subCompany, $imageName]);
        $status = 'added';
    }

    header("Location: references.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$references = $pdo->query("SELECT * FROM referancetbl ORDER BY ReferanceId DESC")->fetchAll();
$editData   = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM referancetbl WHERE ReferanceId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div id="sec-reference" class="mb-5">
        <form action="references.php" method="POST" enctype="multipart/form-data">

            <?php if ($editData): ?>
                <input type="hidden" name="ReferanceId"   value="<?= $editData['ReferanceId'] ?>">
                <input type="hidden" name="current_image" value="<?= $editData['ReferanceImagefile'] ?>">
            <?php endif; ?>

            <div class="card border-0 shadow-sm rounded-3">

                <div class="card-header bg-white border-bottom d-flex align-items-center gap-3 py-3">
                    <div class="rounded-2 d-flex align-items-center justify-content-center"
                         style="width:36px; height:36px; background:#f0fdf4; font-size:16px">🤝</div>
                    <h6 class="mb-0 fw-bold">
                        <?= $editData ? 'Referansı Düzenle' : 'Yeni Referans Ekle' ?>
                    </h6>
                </div>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Şirket Adı</label>
                            <input type="text" name="ReferanceCompanyName" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['ReferanceCompanyName'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Alt Başlık / Sektör</label>
                            <input type="text" name="ReferanceSubCompanyName" class="form-control form-control-sm"
                                   value="<?= htmlspecialchars($editData['ReferanceSubCompanyName'] ?? '') ?>"
                                   required>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label small fw-semibold">Logo / Resim</label>
                            <input type="file" name="ReferanceImagefile" class="form-control form-control-sm">
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-white border-top d-flex justify-content-end gap-2 py-3">
                    <?php if ($editData): ?>
                        <a href="references.php" class="btn btn-sm btn-light">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4">
                        <i class="bi bi-check-circle me-1"></i>
                        <?= $editData ? 'Güncelle' : 'Kaydet' ?>
                    </button>
                </div>

            </div>
        </form>
    </div>

    <!-- Referans Listesi -->
    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
        <div class="bg-light p-3 border-bottom">
            <h6 class="m-0 fw-bold text-dark">
                <i class="bi bi-list-ul me-2"></i>Referans Listesi
            </h6>
        </div>
        <div class="card-body p-0">
            <table class="table table-hover align-middle mb-0 text-center">
                <thead class="table-light">
                    <tr style="font-size:11px; color:#666">
                        <th>ID</th>
                        <th>LOGO</th>
                        <th>ŞİRKET ADI</th>
                        <th>ALT BAŞLIK</th>
                        <th>İŞLEMLER</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($references as $row): ?>
                    <tr>
                        <td class="text-muted small"><?= $row['ReferanceId'] ?></td>
                        <td>
                            <img src="../uploads/<?= htmlspecialchars($row['ReferanceImagefile'] ?: 'no-logo.png') ?>"
                                 class="rounded p-1 border"
                                 style="width:60px; height:40px; object-fit:contain; background:#fff">
                        </td>
                        <td class="fw-bold text-dark"><?= htmlspecialchars($row['ReferanceCompanyName']) ?></td>
                        <td class="text-muted small"><?= htmlspecialchars($row['ReferanceSubCompanyName']) ?></td>
                        <td>
                            <a href="references.php?edit=<?= $row['ReferanceId'] ?>"
                               class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                            <a href="references.php?delete=<?= $row['ReferanceId'] ?>"
                               class="btn btn-sm btn-danger py-0 px-2"
                               onclick="return confirm('Silmek istediğinize emin misiniz?')">Sil</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                    <?php if (empty($references)): ?>
                        <tr>
                            <td colspan="5" class="py-5 text-muted small">
                                Referans kaydı bulunamadı.
                            </td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  COMMENTS.PHP  —  Yorum / Referans Yönetimi
 * ============================================================= */
ob_start();
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $pdo->prepare("DELETE FROM commenttbl WHERE CommentId = ?")->execute([(int)$_GET['delete']]);
    header('Location: comments.php?status=deleted');
    exit;
}

// Kaydetme / güncelleme
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id   = $_POST['CommentId']     ?? null;
    $text = trim($_POST['CommentText']    ?? '');
    $name = trim($_POST['CommentName']    ?? '');
    $job  = trim($_POST['CommentJobname'] ?? '');

    if ($id) {
        $sql = "UPDATE commenttbl SET CommentText=?, CommentName=?, CommentJobname=? WHERE CommentId=?";
        $pdo->prepare($sql)->execute([$text, $name, $job, $id]);
        $status = 'updated';
    } else {
        $sql = "INSERT INTO commenttbl (CommentText, CommentName, CommentJobname) VALUES (?, ?, ?)";
        $pdo->prepare($sql)->execute([$text, $name, $job]);
        $status = 'added';
    }

    header("Location: comments.php?status=$status");
    exit;
}

// Listeleme ve düzenleme modu
$comments = $pdo->query("SELECT * FROM commenttbl ORDER BY CommentId DESC")->fetchAll();
$editData = null;

if (isset($_GET['edit'])) {
    $stmt = $pdo->prepare("SELECT * FROM commenttbl WHERE CommentId = ?");
    $stmt->execute([(int)$_GET['edit']]);
    $editData = $stmt->fetch();
}

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="main-content p-4">
    <div class="container-fluid">

        <!-- Form -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3">
                <h6 class="mb-0 fw-bold text-primary">
                    <i class="bi bi-chat-quote me-2"></i>
                    <?= $editData ? 'Yorumu Düzenle' : 'Yeni Referans/Yorum Ekle' ?>
                </h6>
            </div>
            <form action="" method="POST">
                <?php if ($editData): ?>
                    <input type="hidden" name="CommentId" value="<?= $editData['CommentId'] ?>">
                <?php endif; ?>

                <div class="card-body">
                    <div class="row g-3">

                        <div class="col-md-2">
                            <label class="form-label small fw-bold">İsim Soyisim</label>
                            <input type="text" name="CommentName" class="form-control"
                                   value="<?= htmlspecialchars($editData['CommentName'] ?? '') ?>"
                                   placeholder="Örn: Ahmet Yılmaz"
                                   required>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label small fw-bold">Unvan / Şirket</label>
                            <input type="text" name="CommentJobname" class="form-control"
                                   value="<?= htmlspecialchars($editData['CommentJobname'] ?? '') ?>"
                                   placeholder="Örn: CEO, Yazılım Geliştirici"
                                   required>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label small fw-bold">Açıklama</label>
                            <textarea name="CommentText" class="form-control" rows="1"
                                      placeholder="Müşterinin yorumunu buraya yazın..."
                                      required><?= htmlspecialchars($editData['CommentText'] ?? '') ?></textarea>
                        </div>

                    </div>
                </div>

                <div class="card-footer bg-light d-flex justify-content-end gap-2">
                    <?php if ($editData): ?>
                        <a href="comments.php" class="btn btn-sm btn-secondary">Vazgeç</a>
                    <?php endif; ?>
                    <button type="submit" class="btn btn-sm btn-primary px-4">
                        <?= $editData ? 'Güncelle' : 'Kaydet' ?>
                    </button>
                </div>
            </form>
        </div>

        <!-- Liste -->
        <div class="card shadow-sm border-0">
            <div class="card-body">
                <table class="table table-hover align-middle mb-0 text-center">
                    <thead class="table-light">
                        <tr class="small text-uppercase">
                            <th class="ps-3" style="width:50px">ID</th>
                            <th>Kişi Bilgisi</th>
                            <th>Yorum Özeti</th>
                            <th class="text-center" style="width:150px">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($comments as $row): ?>
                        <tr>
                            <td class="ps-3 fw-bold"><?= $row['CommentId'] ?></td>
                            <td>
                                <div class="fw-bold"><?= htmlspecialchars($row['CommentName']) ?></div>
                                <div class="text-muted small"><?= htmlspecialchars($row['CommentJobname']) ?></div>
                            </td>
                            <td>
                                <small class="text-muted">
                                    <?= mb_strimwidth(htmlspecialchars($row['CommentText']), 0, 100, '...') ?>
                                </small>
                            </td>
                            <td class="text-center">
                                <div class="btn-group">
                                    <a href="comments.php?edit=<?= $row['CommentId'] ?>"
                                       class="btn btn-sm btn-warning py-0 px-2">Düzenle</a>
                                    <a href="comments.php?delete=<?= $row['CommentId'] ?>"
                                       class="btn btn-sm btn-danger py-0 px-2"
                                       onclick="return confirm('Bu yorumu silmek istediğinize emin misiniz?')">Sil</a>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($comments)): ?>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">
                                    Henüz yorum eklenmemiş.
                                </td>
                            </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

<?php ob_end_flush(); ?>


<?php
/* =============================================================
 *  CONTACT.PHP  —  İletişim / Gelen Mesajlar
 * ============================================================= */
require '../db.php';

// Silme işlemi
if (isset($_GET['delete'])) {
    $id = (int)$_GET['delete'];
    $pdo->prepare("DELETE FROM contacttbl WHERE ContactId = ?")->execute([$id]);
    header('Location: contact.php?status=deleted');
    exit;
}

// Okundu olarak işaretle
if (isset($_GET['read'])) {
    $id = (int)$_GET['read'];
    $pdo->prepare("UPDATE contacttbl SET ContactStatus = 1 WHERE ContactId = ?")->execute([$id]);
    header('Location: contact.php?status=marked_read');
    exit;
}

// Form gönderimi (frontend'den gelen mesajlar)
if ($_POST) {
    $name    = htmlspecialchars($_POST['ContactName']    ?? '');
    $surname = htmlspecialchars($_POST['ContactSurname'] ?? '');
    $mail    = htmlspecialchars($_POST['ContactMail']    ?? '');
    $subject = htmlspecialchars($_POST['ContactSubject'] ?? '');
    $message = htmlspecialchars($_POST['ContactMessage'] ?? '');

    $sql = "INSERT INTO contacttbl (ContactName, ContactSurname, ContactMail, ContactSubject, ContactMessage)
            VALUES (?, ?, ?, ?, ?)";
    $pdo->prepare($sql)->execute([$name, $surname, $mail, $subject, $message]);

    header('Location: ../index.php');
    exit;
}

// Mesajları çek
$messages = $pdo->query("SELECT * FROM contacttbl ORDER BY ContactId DESC")->fetchAll(PDO::FETCH_ASSOC);

require 'head.php';
require 'Layout.php';
require 'Script.php';
?>

<div class="container mt-5" id="Contact">
    <div class="card shadow rounded-4 border-0">

        <div class="card-header bg-light text-black py-3 d-flex justify-content-between align-items-center rounded-top-4">
            <h5 class="m-0">
                <i class="bi bi-envelope-paper me-2"></i>Gelen Mesajlar
            </h5>
            <span class="badge bg-primary"><?= count($messages) ?> Mesaj</span>
        </div>

        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">Durum</th>
                            <th>Ad Soyad</th>
                            <th>E-Posta</th>
                            <th>Konu</th>
                            <th class="text-end pe-4">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($messages as $msg): ?>
                        <tr class="<?= $msg['ContactStatus'] == 0 ? 'table-warning' : '' ?>">

                            <td class="ps-4">
                                <?php if ($msg['ContactStatus'] == 0): ?>
                                    <span class="badge rounded-pill bg-danger text-white">Yeni</span>
                                <?php else: ?>
                                    <span class="badge rounded-pill bg-secondary text-white opacity-50">Okundu</span>
                                <?php endif; ?>
                            </td>

                            <td class="fw-bold">
                                <?= htmlspecialchars($msg['ContactName'] . ' ' . $msg['ContactSurname']) ?>
                            </td>

                            <td>
                                <a href="mailto:<?= htmlspecialchars($msg['ContactMail']) ?>"
                                   class="text-decoration-none small text-muted">
                                    <?= htmlspecialchars($msg['ContactMail']) ?>
                                </a>
                            </td>

                            <td><?= htmlspecialchars($msg['ContactSubject']) ?></td>

                            <td class="text-end pe-4">
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-primary py-0 px-2"
                                            data-bs-toggle="modal"
                                            data-bs-target="#msgModal<?= $msg['ContactId'] ?>">
                                        Oku
                                    </button>
                                    <a href="contact.php?delete=<?= $msg['ContactId'] ?>"
                                       class="btn btn-sm btn-danger py-0 px-2"
                                       onclick="return confirm('Bu mesajı kalıcı olarak silmek istediğinize emin misiniz?')">
                                        Sil
                                    </a>
                                </div>
                            </td>

                        </tr>

                        <!-- Mesaj Detay Modal -->
                        <div class="modal fade" id="msgModal<?= $msg['ContactId'] ?>"
                             tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content border-0 shadow rounded-4">

                                    <div class="modal-header border-bottom-0">
                                        <h5 class="modal-title fw-bold">Mesaj Detayı</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>

                                    <div class="modal-body pt-0">
                                        <p class="mb-1 text-muted small text-uppercase fw-bold">Gönderen:</p>
                                        <p class="fw-bold mb-3">
                                            <?= htmlspecialchars($msg['ContactName'] . ' ' . $msg['ContactSurname']) ?>
                                            (<?= htmlspecialchars($msg['ContactMail']) ?>)
                                        </p>

                                        <p class="mb-1 text-muted small text-uppercase fw-bold">Konu:</p>
                                        <p class="fw-bold mb-3 text-primary">
                                            <?= htmlspecialchars($msg['ContactSubject']) ?>
                                        </p>

                                        <hr>

                                        <p class="mb-1 text-muted small text-uppercase fw-bold">Mesaj İçeriği:</p>
                                        <p class="lh-lg bg-light p-3 rounded-3">
                                            <?= nl2br(htmlspecialchars($msg['ContactMessage'])) ?>
                                        </p>
                                    </div>

                                    <div class="modal-footer border-top-0">
                                        <?php if ($msg['ContactStatus'] == 0): ?>
                                            <a href="contact.php?read=<?= $msg['ContactId'] ?>"
                                               class="btn btn-success w-100 rounded-3 px-4">
                                                <i class="bi bi-check-circle me-2"></i>Okundu İşaretle
                                            </a>
                                        <?php else: ?>
                                            <button type="button"
                                                    class="btn btn-secondary w-100 rounded-3"
                                                    data-bs-dismiss="modal">Kapat</button>
                                        <?php endif; ?>
                                    </div>

                                </div>
                            </div>
                        </div>
                        <!-- /Modal -->

                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>
