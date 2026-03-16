import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../data/models/media_model.dart';
import 'BuilderThumbnail.dart';

class ProductMediaGallery extends StatefulWidget {
  final List<ProductMediaModel> mediaItems;
  final ProductEntity product;
  const ProductMediaGallery({
    super.key,
    required this.mediaItems,
    required this.product,
  });

  @override
  State<ProductMediaGallery> createState() => _ProductMediaGalleryState();
}

class _ProductMediaGalleryState extends State<ProductMediaGallery> {
  late CarouselSliderController carouselController;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  bool _isYoutubeInitialized = false;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
    _initializeMediaIfNeeded(_currentIndex);
  }

  @override
  void dispose() {
    _disposeVideoControllers();
    _disposeYoutubeController();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _isVideoInitialized = false;
  }

  void _disposeYoutubeController() {
    _youtubeController?.dispose();
    _youtubeController = null;
    _isYoutubeInitialized = false;
  }

  Future<void> _initializeMediaIfNeeded(int index) async {
    if (index >= widget.mediaItems.length) return;

    final media = widget.mediaItems[index];

    if (media.type == MediaType.video) {
      _disposeVideoControllers();
      _disposeYoutubeController();

      setState(() {
        _isVideoInitialized = false;
      });

      try {
        var uri = Uri.parse(media.url);
        _videoController = VideoPlayerController.networkUrl(uri);

        await _videoController!.initialize();

        if (!mounted) return;

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoController!.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 42),
                  const SizedBox(height: 8),
                  Text(
                    'Erreur de lecture vidéo: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        //print('Erreur d\'initialisation de la vidéo: $e');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
      }
    } else if (media.type == MediaType.youtube) {
      _disposeVideoControllers();
      _disposeYoutubeController();

      setState(() {
        _isYoutubeInitialized = false;
      });

      try {
        final videoId = media.youtubeId;
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
          );

          if (mounted) {
            setState(() {
              _isYoutubeInitialized = true;
            });
          }
        }
      } catch (e) {
        print('Erreur d\'initialisation de la vidéo YouTube: $e');
        if (mounted) {
          setState(() {
            _isYoutubeInitialized = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
            aspectRatio: 1,
            enlargeCenterPage: true,
            scrollDirection: Axis.vertical,
            autoPlay: _currentIndex == 0 ? true : false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              _initializeMediaIfNeeded(index);
            },
          ),
          items:
              widget.mediaItems.asMap().entries.map((entry) {
                final int index = entry.key;
                final ProductMediaModel item = entry.value;

                if (item.type == MediaType.image) {
                  return _buildImageItem(item, index);
                } else if (item.type == MediaType.youtube) {
                  return _buildYoutubeItem(item, index);
                } else {
                  return _buildVideoItem(item, index);
                }
              }).toList(),
        ),
        const SizedBox(height: 10),

        // Miniatures en bas
        SizedBox(
          height: 55,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.mediaItems.length,
            itemBuilder: (context, index) {
              final item = widget.mediaItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: GestureDetector(
                  onTap: () {
                    carouselController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linear,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _currentIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                            width: _currentIndex == index ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: _buildThumbnail(item),
                        ),
                      ),

                      // Indicateur de vidéo
                      if (item.type == MediaType.video ||
                          item.type == MediaType.youtube)
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildThumbnail(ProductMediaModel item) {
    if (item.type == MediaType.youtube && item.thumbnailUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.thumbnailUrl!,
        fit: BoxFit.cover,
        progressIndicatorBuilder:
            (context, url, downloadProgress) => Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
              ),
            ),
        errorWidget:
            (context, url, error) => const Icon(Icons.error, color: Colors.red),
      );
    } else if (item.type == MediaType.video && item.thumbnailUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.thumbnailUrl!,
        fit: BoxFit.cover,
        progressIndicatorBuilder:
            (context, url, downloadProgress) => Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
              ),
            ),
        errorWidget:
            (context, url, error) => const Icon(Icons.error, color: Colors.red),
      );
    } else if (item.type == MediaType.image) {
      return CachedNetworkImage(
        imageUrl: item.url,
        fit: BoxFit.cover,
        progressIndicatorBuilder:
            (context, url, downloadProgress) => Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
              ),
            ),
        errorWidget:
            (context, url, error) => const Icon(Icons.error, color: Colors.red),
      );
    } else {
      // Fallback pour les vidéos sans thumbnail
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.play_arrow, color: Colors.white),
      );
    }
  }

  Widget _buildImageItem(ProductMediaModel item, int index) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: GestureDetector(
          onTap: () {
            _openMediaGallery(context, index, widget.product);
          },
          child: Hero(
            tag: 'product_media_$index',
            child: CachedNetworkImage(
              imageUrl: item.url,
              fit: BoxFit.cover,
              width: 1000.0,
              height: 900,
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 48),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(ProductMediaModel item, int index) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: [
            if (_currentIndex == index &&
                _isVideoInitialized &&
                _chewieController != null)
              // Lecteur vidéo
              Chewie(controller: _chewieController!)
            else
              // Thumbnail avec indicateur de chargement
              Stack(
                alignment: Alignment.center,
                children: [
                  // Thumbnail
                  if (item.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white, size: 48),
                      ),
                    ),

                  // Indicateur de chargement ou bouton play
                  if (_currentIndex == index && !_isVideoInitialized)
                    const CircularProgressIndicator()
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                ],
              ),

            // Bouton pour ouvrir la vidéo en plein écran
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _openMediaGallery(context, index, widget.product);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeItem(ProductMediaModel item, int index) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: [
            if (_currentIndex == index &&
                _isYoutubeInitialized &&
                _youtubeController != null)
              // Lecteur YouTube
              YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).primaryColor,
                progressColors: ProgressBarColors(
                  playedColor: Theme.of(context).primaryColor,
                  handleColor: Theme.of(context).primaryColorDark,
                ),
              )
            else
              // Thumbnail avec indicateur de chargement
              Stack(
                alignment: Alignment.center,
                children: [
                  // Thumbnail
                  if (item.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.movie, color: Colors.white, size: 48),
                      ),
                    ),

                  // Indicateur de chargement ou bouton play
                  if (_currentIndex == index && !_isYoutubeInitialized)
                    const CircularProgressIndicator()
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                ],
              ),

            // Bouton pour ouvrir la vidéo en plein écran
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _openMediaGallery(context, index, widget.product);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMediaGallery(
    BuildContext context,
    int initialIndex,
    ProductEntity product,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MediaGalleryView(
              mediaItems: widget.mediaItems,
              initialIndex: initialIndex,
              product: product,
            ),
      ),
    );
  }
}

class MediaGalleryView extends StatefulWidget {
  final List<ProductMediaModel> mediaItems;
  final ProductEntity product;
  final int initialIndex;

  const MediaGalleryView({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    required this.product,
  });

  @override
  State<MediaGalleryView> createState() => _MediaGalleryViewState();
}

class _MediaGalleryViewState extends State<MediaGalleryView> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  bool _isYoutubeInitialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeMediaIfNeeded(_currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disposeVideoControllers();
    _disposeYoutubeController();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _isVideoInitialized = false;
  }

  void _disposeYoutubeController() {
    _youtubeController?.dispose();
    _youtubeController = null;
    _isYoutubeInitialized = false;
  }

  Future<void> _initializeMediaIfNeeded(int index) async {
    if (index >= widget.mediaItems.length) return;

    final media = widget.mediaItems[index];

    if (media.type == MediaType.video) {
      _disposeVideoControllers();
      _disposeYoutubeController();

      setState(() {
        _isVideoInitialized = false;
      });

      try {
        var videoUri = Uri.parse(media.url);
        _videoController = VideoPlayerController.networkUrl(videoUri);

        await _videoController!.initialize();

        if (!mounted) return;

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoController!.value.aspectRatio,
          allowFullScreen: true,
          allowMuting: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 42),
                  const SizedBox(height: 8),
                  Text(
                    'Erreur de lecture vidéo: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        print('Erreur d\'initialisation de la vidéo: $e');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
      }
    } else if (media.type == MediaType.youtube) {
      _disposeVideoControllers();
      _disposeYoutubeController();

      setState(() {
        _isYoutubeInitialized = false;
      });

      try {
        final videoId = media.youtubeId;
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              forceHD: true,
            ),
          );

          if (mounted) {
            setState(() {
              _isYoutubeInitialized = true;
            });
          }
        }
      } catch (e) {
        print('Erreur d\'initialisation de la vidéo YouTube: $e');
        if (mounted) {
          setState(() {
            _isYoutubeInitialized = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.mediaItems.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              Share.share(
                'Découvrez ${widget.product.name} à prix réduit sur Auto Pro : https://auto-pro.uvatis.com/catalogue/view/${widget.product.slug}',
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Galerie de médias
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _initializeMediaIfNeeded(index);
            },
            itemBuilder: (context, index) {
              final media = widget.mediaItems[index];

              if (media.type == MediaType.image) {
                return _buildFullscreenImage(media, index);
              } else if (media.type == MediaType.youtube) {
                return _buildFullscreenYoutube(media, index);
              } else {
                return _buildFullscreenVideo(media, index);
              }
            },
          ),

          // Miniatures en bas
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: widget.mediaItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.mediaItems[index];
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _currentIndex == index
                                        ? Colors.white
                                        : Colors.grey,
                                width: _currentIndex == index ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: buildThumbnail(item),
                            ),
                          ),

                          // Indicateur de vidéo
                          if (item.type == MediaType.video ||
                              item.type == MediaType.youtube)
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenImage(ProductMediaModel media, int index) {
    return PhotoView(
      imageProvider: CachedNetworkImageProvider(media.url),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2,
      heroAttributes: PhotoViewHeroAttributes(tag: 'product_media_$index'),
      loadingBuilder:
          (context, event) => const Center(child: CircularProgressIndicator()),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }

  Widget _buildFullscreenVideo(ProductMediaModel media, int index) {
    if (_currentIndex == index &&
        _isVideoInitialized &&
        _chewieController != null) {
      return Center(child: Chewie(controller: _chewieController!));
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail
          if (media.thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: media.thumbnailUrl!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.movie, color: Colors.white, size: 48),
                    ),
                  ),
            )
          else
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.movie, color: Colors.white, size: 48),
              ),
            ),

          // Indicateur de chargement ou bouton play
          if (_currentIndex == index && !_isVideoInitialized)
            const CircularProgressIndicator()
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      );
    }
  }

  Widget _buildFullscreenYoutube(ProductMediaModel media, int index) {
    if (_currentIndex == index &&
        _isYoutubeInitialized &&
        _youtubeController != null) {
      return Center(
        child: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Theme.of(context).primaryColor,
          progressColors: ProgressBarColors(
            playedColor: Theme.of(context).primaryColor,
            handleColor: Theme.of(context).primaryColorDark,
          ),
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Thumbnail
          if (media.thumbnailUrl != null)
            CachedNetworkImage(
              imageUrl: media.thumbnailUrl!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              progressIndicatorBuilder:
                  (context, url, downloadProgress) => Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.movie, color: Colors.white, size: 48),
                    ),
                  ),
            )
          else
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.movie, color: Colors.white, size: 48),
              ),
            ),

          // Indicateur de chargement ou bouton play
          if (_currentIndex == index && !_isYoutubeInitialized)
            const CircularProgressIndicator()
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
        ],
      );
    }
  }
}
