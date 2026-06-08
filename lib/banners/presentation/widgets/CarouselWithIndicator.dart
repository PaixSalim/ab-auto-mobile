import 'package:auto/banners/presentation/bloc/remote_banner_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:icons_plus/icons_plus.dart';

class CarouselWithIndicator extends StatefulWidget {
  const CarouselWithIndicator({super.key});

  @override
  State<CarouselWithIndicator> createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _currentIndex = 0;
  List<String> imageUrls = [
    "https://www.uvatis.com",
    "https://www.uvatis.com",
    "https://www.uvatis.com",
    "https://www.uvatis.com",
    "https://www.uvatis.com",
  ];
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Méthode pour ouvrir WhatsApp
  void _launchWhatsApp() async {
    const phoneNumber = '+22603231010'; // Numéro de téléphone à configurer
    final url = 'https://wa.me/$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double carouselWidth = MediaQuery.of(context).size.width;
    return Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              // Carousel
              SizedBox(
                width: carouselWidth,
                child: BlocBuilder<RemoteBannerBloc, RemoteBannerState>(
            builder: (context, state) {
              if (state is RemoteBannerLoading) {
                return CarouselSlider(
                  items:
                      imageUrls.map((imageUrl) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Lottie.asset(
                            fit: BoxFit.cover,
                            width: double.infinity,
                            'assets/animations/lottie/loading-image.json',
                          ),
                        );
                      }).toList(),
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: false,
                    viewportFraction: 1.2,
                    aspectRatio: 16 / 6,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                );
              }
              if (state is RemoteBannerDone) {
                return CarouselSlider(
                  items:
                      state.banners!.map((banner) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: banner.image!,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            progressIndicatorBuilder:
                                (
                                  context,
                                  url,
                                  downloadProgress,
                                ) => Lottie.asset(
                                  'assets/animations/lottie/loading-image.json',
                                ),
                            errorWidget:
                                (context, url, error) => Lottie.asset(
                                  'assets/animations/lottie/error-network.json',
                                ),
                          ),
                        );
                      }).toList(),
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: false,
                    viewportFraction: 1.2,
                    aspectRatio: 16 / 6,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                );
              }

              if (state is RemoteBannerError) {
                CarouselSlider(
                  items:
                      imageUrls.map((imageUrl) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Lottie.asset(
                            fit: BoxFit.cover,
                            width: double.infinity,
                            'assets/animations/lottie/error-network.json',
                          ),
                        );
                      }).toList(),
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: false,
                    viewportFraction: 0.9, // Occupe 90% de la largeur de l'écran
                    enlargeStrategy: CenterPageEnlargeStrategy.height, // Agrandit en hauteur
                    aspectRatio: 16 / 6,
                    padEnds: false, // Pas d'espace supplémentaire au début et à la fin
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                );
              }
              return Text('');
            },
          )),
              
              // Bouton WhatsApp flottant à droite
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                  onPressed: _launchWhatsApp,
                  backgroundColor: const Color(0xFF25D366), // Couleur WhatsApp
                  mini: true,
                  child: const Icon(
                    Bootstrap.whatsapp,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Indicateurs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                imageUrls.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _carouselController.animateToPage(entry.key),
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Theme.of(context).primaryColor)
                            .withValues(
                              alpha: _currentIndex == entry.key ? 0.9 : 0.4,
                            ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
        ],
    );
  }
}
