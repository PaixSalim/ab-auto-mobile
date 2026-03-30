import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ChatbotService {
  constructor(private readonly prisma: PrismaService) {}

  async generateDescription(prompt: string) {
    // Ici nous pourrions intégrer Google Gemini ou OpenAI
    // Pour l'instant, nous allons simuler une réponse simple
    const mockResponse = {
      message: `En tant qu'assistant spécialisé pour Auto-Pro, je peux vous aider avec:
      - Informations détaillées sur nos produits
      - Recommandations personnalisées
      - Comparaisons de prix
      - Assistance technique 24/7
      
      Pour ${prompt}, voici ma réponse:
      
      Je suis l'assistant IA d'Auto-Pro, conçu pour vous fournir les meilleures informations sur nos produits et services. Basé sur votre demande, je vous propose:
      
      ${this.generateProductInfo(prompt)}`
    };

    return mockResponse;
  }

  async generateFeatures(prompt: string) {
    // Génération de fonctionnalités formatées
    const features = [];
    
    // Simulation de génération de 6 fonctionnalités
    for (let i = 0; i < 6; i++) {
      features.push(`Fonctionnalité ${i + 1}: ${this.generateFeatureDescription(i + 1)}`);
    }

    return {
      features: features.join('\n'),
      promptTokenCount: 6
    };
  }

  async chat(prompt: string, products: any[]) {
    // Formatage des produits pour le chatbot
    const formattedProducts = products.map(p => ({
      name: p.name,
      price: p.price,
      category: p.category?.name || 'Non catégorisé',
      brand: p.brand?.name || 'Non défini',
      description: p.description || 'Aucune description disponible',
      state: p.state || 'Disponible',
      warranty: p.warranty || 'Non spécifié'
    }));

    const response = {
      message: `Voici les informations sur les produits disponibles:
      
      ${formattedProducts.map(p => `
      📦 ${p.name}
      💰 Prix: ${p.price} FCFA
      🏷️ Catégorie: ${p.category?.name || 'Non définie'}
      🏷️ Marque: ${p.brand?.name || 'Non définie'}
      📝 État: ${p.state || 'Disponible'}
      📄 Description: ${p.description || 'Aucune description'}
      🔧 Garantie: ${p.warranty || 'Non spécifi'}
      `).join('\n')}
      
      Pour plus d'informations sur un produit spécifique, n'hésitez pas à me contacter !
      `,
      products: formattedProducts
    };

    return response;
  }

  private generateProductInfo(prompt: string): string {
    const features = [
      'Écran tactile de 6.5 pouces',
      'Batterie longue durée (48h)',
      'Double caméra 108MP + 8MP',
      'Stockage 128GB',
      'Design épuré et moderne',
      'Protection IP68',
      'Charge rapide USB-C',
      'Étanchéité IP68',
      'Compatible avec tous nos accessoires',
      'Mise à jour OTA automatique'
    ];

    return features[0] || 'Fonctionnalités de pointe multimédia avancées';
  }

  private generateFeatureDescription(index: number): string {
    const descriptions = [
      'Un smartphone haut de gamme avec des caractéristiques exceptionnelles',
      'Une tablette professionnelle pour travail mobile',
      'Un ordinateur portable performant pour professionnels',
      'Un système audio immersif de haute qualité',
      'Une solution de domotique complète',
      'Un kit de réalité virtuelle pour gaming',
      'Un appareil photo professionnel avec objectifs interchangeables'
    ];

    return descriptions[index] || 'Caractéristiques techniques détaillées';
  }
}
