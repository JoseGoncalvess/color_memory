import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_color/src/core/helpers/ad_helper.dart';

class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key});
  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAd? _ad;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _ad = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) { if (mounted) setState(() => _loaded = true); },
          onAdFailedToLoad: (ad, _) { ad.dispose(); _ad = null; },
        ),
      )..load();
    }
  }
  @override
  void dispose() { _ad?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _loaded && _ad != null
      ? SafeArea(child: SizedBox(height: 50, child: Center(
          child: SizedBox(width: 320, height: 50, child: AdWidget(ad: _ad!)))))
      : const SizedBox.shrink();
}
