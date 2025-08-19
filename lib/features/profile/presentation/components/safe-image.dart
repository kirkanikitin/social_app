import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

bool isValidHttpUrl(String? url) {
  if (url == null) return false;
  final s = url.trim();
  if (s.isEmpty) return false;
  if (s.toLowerCase() == 'null') return false;
  Uri? uri;
  try {
    uri = Uri.parse(s);
  } catch (_) {
    return false;
  }
  return (uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      (uri.host.isNotEmpty));
}

Widget avatarFromUrl({
  required BuildContext context,
  required String? url,
  required double size,
}) {
  if (!isValidHttpUrl(url)) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Theme.of(context).colorScheme.inversePrimary),
      ),
      child: Icon(Icons.person,
          size: size * 0.58,
          color: Theme.of(context).colorScheme.inverseSurface),
    );
  }

  return CachedNetworkImage(
    imageUrl: url!,
    imageBuilder: (context, imageProvider) => Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    ),
    placeholder: (context, _) => SizedBox(
      height: size,
      width: size,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
      ),
    ),
    errorWidget: (context, _, __) => Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: Theme.of(context).colorScheme.inversePrimary),
      ),
      child: Icon(Icons.person,
          size: size * 0.58,
          color: Theme.of(context).colorScheme.inverseSurface),
    ),
  );
}

Widget safeNetworkImage({
  required BuildContext context,
  required String? url,
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  Widget? fallback, // опциональный кастомный фолбек
}) {
  if (!isValidHttpUrl(url)) {
    return fallback ??
        Container(
          height: height,
          width: width,
          color: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.error_outline),
        );
  }

  return CachedNetworkImage(
    imageUrl: url!,
    height: height,
    width: width,
    fit: fit,
    placeholder: (context, _) => SizedBox(height: height, width: width),
    errorWidget: (context, _, __) =>
    fallback ??
        Container(
          height: height,
          width: width,
          color: Theme.of(context).colorScheme.secondary,
          child: const Icon(Icons.error_outline),
        ),
  );
}