package com.nuveli.app

import io.flutter.embedding.android.FlutterFragmentActivity

// Extends FlutterFragmentActivity (not FlutterActivity) so the `health`
// plugin can use registerForActivityResult when prompting for Health
// Connect permissions on Android 14+. Required by health >= 13.x.
class MainActivity : FlutterFragmentActivity()
