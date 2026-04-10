<?php
// Configuration
$to_email = 'tiama.barkley@gmail.com.com';
$subject_prefix = '[DEMANDE SUPPRESSION COMPTE]';

// Headers pour empêcher le spam et assurer l'encodage correct
$headers = [
    'From: noreply@' . $_SERVER['HTTP_HOST'],
    'Reply-To: ' . filter_var($_POST['email'], FILTER_VALIDATE_EMAIL) ?: 'noreply@' . $_SERVER['HTTP_HOST'],
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset=UTF-8',
    'X-Mailer: PHP/' . phpversion()
];

// Nettoyage et validation des données
function clean_input($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

// Vérifier si le formulaire a été soumis
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    
    // Récupérer et nettoyer les données
    $fullName = clean_input($_POST['fullName'] ?? '');
    $email = clean_input($_POST['email'] ?? '');
    $phone = clean_input($_POST['phone'] ?? '');
    $reason = clean_input($_POST['reason'] ?? '');
    $details = clean_input($_POST['details'] ?? '');
    
    // Validation
    $errors = [];
    
    if (empty($fullName)) {
        $errors[] = 'Le nom complet est obligatoire';
    }
    
    if (empty($reason)) {
        $errors[] = 'La raison de la suppression est obligatoire';
    }
    
    // Vérifier les confirmations
    $confirmation1 = isset($_POST['confirmation1']) ? $_POST['confirmation1'] : '';
    $confirmation2 = isset($_POST['confirmation2']) ? $_POST['confirmation2'] : '';
    $confirmation3 = isset($_POST['confirmation3']) ? $_POST['confirmation3'] : '';
    
    if ($confirmation1 !== 'on' || $confirmation2 !== 'on' || $confirmation3 !== 'on') {
        $errors[] = 'Toutes les confirmations sont obligatoires';
    }
    
    // Si there are errors, return them
    if (!empty($errors)) {
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Erreur de validation',
            'errors' => $errors
        ]);
        exit;
    }
    
    // Créer le contenu de l'email
    $email_content = "
DEMANDE DE SUPPRESSION DE COMPTE

========================================
INFORMATIONS UTILISATEUR
========================================
Nom complet: $fullName
Email: " . ($email ?: 'Non spécifié') . "
Téléphone: " . ($phone ?: 'Non spécifié') . "

========================================
RAISON DE LA SUPPRESSION
========================================
Raison principale: $reason
Détails supplémentaires: " . ($details ?: 'Aucun') . "

========================================
CONFIRMATIONS
========================================
- Comprend la nature irréversible: OUI
- Comprend la perte des données: OUI
- Confirme la suppression: OUI

========================================
INFORMATIONS TECHNIQUES
========================================
Date de la demande: " . date('d/m/Y H:i:s') . "
Adresse IP: " . $_SERVER['REMOTE_ADDR'] . "
Navigateur: " . $_SERVER['HTTP_USER_AGENT'] . "
Site d'origine: " . $_SERVER['HTTP_REFERER'] . "
========================================";

    // Sujet de l'email
    $subject = $subject_prefix . ' ' . $fullName;
    
    // Envoyer l'email
    if (mail($to_email, $subject, $email_content, implode("\r\n", $headers))) {
        // Succès
        header('Content-Type: application/json');
        echo json_encode([
            'success' => true,
            'message' => 'Votre demande de suppression a été envoyée avec succès. Nous vous contacterons dans les plus brefs délais.'
        ]);
    } else {
        // Erreur d'envoi
        header('Content-Type: application/json');
        echo json_encode([
            'success' => false,
            'message' => 'Une erreur est survenue lors de l\'envoi de votre demande. Veuillez réessayer ultérieurement.'
        ]);
    }
} else {
    // Si la méthode n'est pas POST
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Méthode de requête non autorisée'
    ]);
}
?>
