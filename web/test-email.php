<?php
// Script de test pour vérifier la fonction mail() de PHP
echo "<h1>Test de la fonction mail() PHP</h1>";

// Test simple
$to = 'tiama.barkley@gmail.com.com';
$subject = 'Test Email from PHP';
$message = 'Ceci est un test pour vérifier que la fonction mail() fonctionne.';
$headers = 'From: test@localhost' . "\r\n" .
           'Reply-To: test@localhost' . "\r\n" .
           'X-Mailer: PHP/' . phpversion();

echo "<p>Tentative d'envoi d'email à: $to</p>";
echo "<p>Sujet: $subject</p>";
echo "<p>Message: $message</p>";

if (mail($to, $subject, $message, $headers)) {
    echo "<p style='color: green;'><strong>SUCCÈS:</strong> L'email a été envoyé avec succès!</p>";
} else {
    echo "<p style='color: red;'><strong>ERREUR:</strong> L'envoi d'email a échoué.</p>";
    echo "<p>Vérifiez votre configuration PHP (php.ini) pour les paramètres SMTP.</p>";
}

echo "<h2>Informations de configuration PHP:</h2>";
echo "<p>Version PHP: " . phpversion() . "</p>";
echo "<p>Fichier php.ini: " . php_ini_loaded_file() . "</p>";

// Afficher les paramètres mail pertinents
$mail_params = ['SMTP', 'smtp_port', 'sendmail_from', 'sendmail_path'];
echo "<h2>Paramètres mail dans php.ini:</h2>";
foreach ($mail_params as $param) {
    $value = ini_get($param);
    echo "<p><strong>$param:</strong> " . ($value ?: 'non défini') . "</p>";
}
?>
