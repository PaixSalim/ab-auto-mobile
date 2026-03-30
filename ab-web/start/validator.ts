import vine, { SimpleMessagesProvider } from '@vinejs/vine'

const messages = {
  'string': 'Ce champ {{ field }} doit être une chaine de caractères',
  'email': 'Veuillez bien vouloir entrer un email valide',
  'required': 'Ce champ est obligatoire',

  'customerName': 'Veuillez saisir votre nom svp',
  'customerName.minLength': "Veuillez entrer un nom d'au moins au moins 3 caractères",
  'phoneNumber.minLength': 'Veuillez entrer un numéro whatsapp valide',
  'city.minLength': 'Veuillez entrer un nom de ville valide',

  'password': 'Veuillez entrer un mot de passe ',
  'password.minLength': 'Veuillez entrer au moins 8 caractères',
  'password.regex':
    'Veuillez entrer au moins 1 lettre majuscule, 1 minuscule, 1 chiffre et 1 caractère special($,%,@)',
}

vine.messagesProvider = new SimpleMessagesProvider(messages)
