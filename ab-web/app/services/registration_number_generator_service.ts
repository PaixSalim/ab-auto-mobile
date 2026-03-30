import User from '#models/user'

export default class RegistrationNumberGeneratorService {
  public static async generate(): Promise<string> {
    const year = new Date().getFullYear()
    let isUnique = false
    let registrationNumber = ''

    while (!isUnique) {
      const random = Math.floor(1000 + Math.random() * 9000)
      registrationNumber = `VND-${year}-${random}`

      const existing = await User.query().where('registration_number', registrationNumber).first()
      if (!existing) {
        isUnique = true
      }
    }

    return registrationNumber
  }
}