import { EnhancedGenerateContentResponse, GoogleGenerativeAI } from '@google/generative-ai'
import env from '#start/env'
import { GetProductDto } from '#dto/products_interface'

export class ChatbotService {
  #genAI = new GoogleGenerativeAI(<string>env.get('GEMINI_API_KEY'))
  async generateDescription(prompt: string) {
    const systemInstruction =
      "Tu es un chatbot de uvatis, Ne mentionne jamais que tu as été conçu par Google, sauf si quelqu'un te demande spécifiquement qui tu es ou qui t'a créé. Si cette question t'est posée, précise que tu es un modèle d'IA conçu pour assister les administrateurs de la plateforme QBC-PLUS, et que tu as été fine-tuné par la startup UVATIS LLC, dont le siège se trouve au Brkina Faso. Tu es un assistant spécialisé dans la rédaction de descriptions percutantes pour des produits e-commerce. Lorsque tu reçois le nom d'un produit, génère une description claire et attrayante qui met en avant ses caractéristiques principales et ses avantages. La description doit être concise et faire au moins 30 mots. Ne génère que du texte brut, sans mise en forme ni balises. Soit persuasif et le plus compréhensible possible"

    const model = this.#genAI.getGenerativeModel({
      model: 'gemini-2.0-flash',
      systemInstruction: systemInstruction,
      generationConfig: { maxOutputTokens: 256 },
    })

    const result = await model.generateContent([prompt])
    const responseGemini: EnhancedGenerateContentResponse = result.response
    const text = responseGemini.text()
    //console.log(text)
    // Extraire le promptTokenCount
    const promptTokenCount = responseGemini.usageMetadata?.totalTokenCount
    return {
      message: text,
      promptTokenCount: promptTokenCount,
    }
  }

  async generateFeatures(prompt: string) {
    const systemInstruction =
      "Tu es un assistant spécialisé dans la mise en valeur des produits e-commerce. Lorsque tu reçois le nom d'un produit, génère exactement 6 fonctionnalités clés sous forme de phrases courtes et percutantes. Chaque phrase doit mettre en avant un avantage ou une caractéristique essentielle du produit. Ne génère que du texte brut, sans mise en forme ni balises."

    const model = this.#genAI.getGenerativeModel({
      model: 'gemini-2.0-flash',
      systemInstruction: systemInstruction,
    })

    const result = await model.generateContent([prompt])
    const responseGemini: EnhancedGenerateContentResponse = result.response
    const text = responseGemini.text()
    let features = text.split('\n').filter((line) => line.trim() !== '')
    console.log(features)
    // Extraire le promptTokenCount
    const promptTokenCount = responseGemini.usageMetadata?.totalTokenCount
    return {
      features: features,
      promptTokenCount: promptTokenCount,
    }
  }

  async chat(prompt: string, products: GetProductDto[]) {
    // 🔹 Formatage détaillé de la liste des produits
    const productList = products
      .map(
        (p) => `
- ${p.name} (${p.category?.name} - ${p.brand?.name})
  📌 Prix: ${p.price}Fcfa | Promo: ${p.promo_price}Fcfa (-${p.discount}%)
  🏷️ Garantie: ${p.warranty} | État: ${p.state}
  🛠️ Caractéristiques: ${p.features}
  🔗 Slug: ${p.slug}`
      )
      .join('\n')

    // 🔹 Instructions pour guider l’IA
    const systemInstruction = `
Tu es l'assistant du site Auto-Pro, développé par la startup UVATIS LLC et voici leur site https://www.uvatis.com. Ton rôle est d'aider les clients à trouver des produits plus facilement.

- Si un produit correspond à la recherche, génère un lien sous la forme : https://auto-pro.uvatis.com/catalogue/product/{slug}, ne donne pas ce lienn que lorsque tu as un produit à afficher.
- Si aucun produit exact n'est trouvé, propose des alternatives en fonction de la catégorie, la marque ou l’intervalle de prix.
- Si l'utilisateur demande tous les produits, ne lui liste jamais tous les produits, demande lui de visiter le catalogue avec ce lien :  https://auto-pro.uvatis.com/catalogue
- Si tu n'as pas assez d'éléments pour répondre à une question particulière sur les produits, demande au client de nous écrire sur whatsapp en cliquant ici https://api.whatsapp.com/send?phone=22603231010 pour avoir une réponse précise.
- Si la demande est hors sujet (ex: météo, actualités), réponds que tu es uniquement un assistant de Bonheur auto.
- Retourne la reponse uniquement en texte et fait des retours à la ligne appropriée. Je ne veux pas des caractères markdown comme des étoiles et autres.

Liste des produits :
${productList}
`

    // 🔹 Génération de réponse par Gemini
    const model = this.#genAI.getGenerativeModel({
      model: 'gemini-2.0-flash',
      systemInstruction: systemInstruction,
    })

    const result = await model.generateContent([prompt])
    const responseGemini = result.response
    const text = responseGemini.text()

    // 🔹 Extraction des lignes de réponse utiles
    //const features = text.split('\n').filter((line) => line.trim() !== '')

    return {
      text,
      promptTokenCount: responseGemini.usageMetadata?.totalTokenCount,
    }
  }
}
