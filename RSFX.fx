/**
 *                 
 *  RSFX           
 *    Reticle SFX  
 *          v1.00  
 *                 
 * A ReShade shader to draw a crosshair
 * By applying special effects to the game
 * Rather than just adding color
 * 
 *
 * A nice way to keep the immersion of the game and not need a gaudy color
 * But still be a sweaty tryhard with sick preaim and center awareness
 *
 *
 
  Currently in feature-creep status

  Coming in v1.x
    Alternate behaviour for mouse/key down
    Plugin system with headers
    Cross Options ( draw on/off for each limb (replaces t-shape) )
    More reticles (X/chevron, fullscreen, png texture...?)
    Blend modes per crosshair
    More filters (hue rotation, luma rotation, monochrome, passthrough, etc)
    Better implementation of reticle vars (easier to expand/upgrade)
  
  
  Based on:
    reshade-xhair 2.0.1 Copyright 2020 peelz
  
 */

#include "Reshade.fxh"

#define CATEGORY_GENERAL "  ---==<{[  General  ]}>==---  "
#define CATEGORY_RSFX_CROSS "  ---==<{[   CROSS   ]}>==---  "
#define CATEGORY_RSFX_DOT "  ---==<{[    DOT    ]}>==---  "
#define CATEGORY_RSFX_CIRCLE "  ---==<{[  CIRCLE   ]}>==---  "

#define MAX_CROSS_OUTLINE_THICKNESS 200
#define MAX_CIRCLE_OUTLINE_THICKNESS 200.0

#if !defined(__RESHADE__) || __RESHADE__ < 40001
  #define UI_TYPE_SLIDER "drag"
#else
  #define UI_TYPE_SLIDER "slider"
#endif



/**
 * General Settings
 */

uniform bool ReticleDrawCross <
  ui_category = CATEGORY_GENERAL;
  ui_label = "Draw Cross";
  ui_tooltip = "Draw Cross Crosshair";
> = 1;

uniform bool ReticleDrawTshape <
  ui_category = CATEGORY_GENERAL;
  ui_label = "Draw T Shape";
  ui_tooltip = "Draw T-Shaped Crosshair";
> = 1;

uniform bool ReticleDrawDot <
  ui_category = CATEGORY_GENERAL;
  ui_label = "Draw Dot";
  ui_tooltip = "Draw Dot Crosshair";
> = 1;

uniform bool ReticleDrawCircle <
  ui_category = CATEGORY_GENERAL;
  ui_label = "Draw Circle";
  ui_tooltip = "Draw Circle Crosshair";
> = 1;

uniform float ReticleOpacity <
  ui_category = CATEGORY_GENERAL;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_label = "Reticle Opacity";
> = 1.0;

uniform int HideOnRMB <
  ui_category = CATEGORY_GENERAL;
  ui_type = "combo";
  ui_items = "Hold\0Toggle\0Disabled\0";
  ui_label = "Hide on RMB";
  ui_tooltip = "Controls whether the crosshair should be hidden when clicking the right mouse button.";
> = 0;

uniform bool InvertHideOnRMB <
  ui_category = CATEGORY_GENERAL;
  ui_label = "Invert Hide on RMB";
  ui_tooltip = "Inverts the behavior of 'Invert on RMB'";
> = 0;

uniform int OffsetX <
  ui_category = CATEGORY_GENERAL;
  ui_type = UI_TYPE_SLIDER;
  ui_min = -(BUFFER_WIDTH / 2); ui_max = (BUFFER_WIDTH / 2);
  ui_label = "X Axis Shift";
  ui_tooltip = "Offsets the crosshair horizontally from the center of the screen.";
> = 0;

uniform int OffsetY <
  ui_category = CATEGORY_GENERAL;
  ui_type = UI_TYPE_SLIDER;
  ui_min = -(BUFFER_HEIGHT / 2); ui_max = (BUFFER_HEIGHT / 2);
  ui_label = "Y Axis Shift";
  ui_tooltip = "Offsets the crosshair vertically from the center of the screen.";
> = 0;



/**
 * Cross Reticle Settings
 */

uniform float3 CrossColor <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = "color";
  ui_label = "Color";
  ui_spacing = 5;
  ui_category_closed = true;
> = float3(0.733333, 0.039215, 0.96078431372549019608); // bropink

uniform float CrossOpacity <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Opacity";
> = 1.0;

uniform float CrossFilter <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Filter Background";
  ui_tooltip = "Filters the game color beneath the cross";
> = 0;

uniform int CrossWidth <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 1; ui_max = 200;
  ui_step = 1;
  ui_label = "Width";
  ui_spacing = 2;
> = 6;

uniform int CrossHeight <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 1; ui_max = 200;
  ui_step = 1;
  ui_label = "Height";
> = 6;

uniform int CrossThickness <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = 200;
  ui_step = 1;
  ui_label = "Thickness";
> = 1;

uniform int CrossGap <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = 200;
  ui_step = 1;
  ui_label = "Gap";
> = 3;



/**
 * Cross Reticle Outline Settings
 */

uniform bool CrossOutlineEnabled <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_label = "Enable Outline";
> = 1;

uniform bool CrossOutlineGlowEnabled <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_label = "Enable Outline Glow";
> = true;

uniform float3 CrossOutlineColor <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = "color";
  ui_label = "Outline Color";
> = float3(0.0, 0.0, 0.0);

uniform float CrossOutlineOpacity <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Outline Opacity";
> = 1.0;

uniform float CrossOutlineFilter <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Filter Background";
  ui_tooltip = "Filters the game color beneath the cross outline";
> = 0;

uniform float f_crossOutlineSharpness <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = (MAX_CROSS_OUTLINE_THICKNESS);
  ui_step = 0.1;
  ui_label = "Outline Sharpness";
  ui_tooltip = "Controls how many pixels should be rendered at 100% opaque around the crosshair (recommended: 1 or 0).";
> = 1;
#define CrossOutlineSharpness (max(f_crossOutlineSharpness, 0))

uniform float f_crossOutlineGlow <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = MAX_CROSS_OUTLINE_THICKNESS;
  ui_step = 0.1;
  ui_label = "Outline Glow";
  ui_tooltip = "Controls how many outline glow pixels should be rendered around the sharp outline.";
> = 2;
#define CrossOutlineGlow (max(f_crossOutlineGlow, 0))

uniform float CrossOutlineGlowOpacity <
  ui_category = CATEGORY_RSFX_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Outline Glow Opacity";
> = 0.15;



/**
 * Dot Reticle Settings
 */

uniform int DotType <
  ui_category = CATEGORY_RSFX_DOT;
  ui_type = "combo";
  ui_items = "Circle\0Square\0";
  ui_label = "Dot Shape";
  ui_tooltip = "Select shape to use for center dot";
  ui_spacing = 5;
  ui_category_closed = true;
> = 0;

uniform float3 DotColor <
  ui_category = CATEGORY_RSFX_DOT;
  ui_type = "color";
  ui_label = "Dot Color";
> = float3(0.733333, 0.039215, 0.96078431372549019608);

uniform float DotOpacity <
  ui_category = CATEGORY_RSFX_DOT;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Dot Opacity";
> = 1.0;

uniform float DotFilter <
  ui_category = CATEGORY_RSFX_DOT;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Filter Background";
  ui_tooltip = "Filters the game color beneath the dot";
> = 0;

uniform int DotSize <
  ui_category = CATEGORY_RSFX_DOT;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 1; ui_max = 30;
  ui_step = 30/100;
  ui_label = "Dot Size";
> = 1;



/**
 * Circle Reticle Settings
 */

uniform float3 CircleColor <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = "color";
  ui_label = "Color";
  ui_spacing = 5;
  ui_category_closed = true;
> = float3(0.0, 1.0, 0.0);

uniform float CircleOpacity <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Opacity";
> = 1.0;

uniform float CircleFilter <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Filter Background";
  ui_tooltip = "Filters the game color beneath the circle";
> = 0;

uniform float CircleThickness <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 20.0;
  ui_step = 20.0/200;
  ui_label = "Thickness";
> = 2.0;

uniform float CircleGapRadius <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 20.0;
  ui_step = 20.0/100;
  ui_label = "Gap Radius";
> = 4.0;



/**
 * Circle Reticle Outline Settings
 */

uniform bool CircleOutlineEnabled <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_label = "Enable Outline";
> = 1;

uniform bool CircleOutlineGlowEnabled <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_label = "Enable Outline Glow";
> = true;

uniform float3 CircleOutlineColor <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = "color";
  ui_label = "Outline Color";
> = float3(0.0, 0.0, 0.0);

uniform float CircleOutlineOpacity <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_label = "Outline Opacity";
> = 1.0;

uniform float CircleInnerOutlineGlowOpacity <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Inner Outline Glow Opacity";
> = 0.15;

uniform float CircleOuterOutlineGlowOpacity <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Outer Outline Glow Opacity";
> = 0.15;

uniform float CircleOutlineFilter <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "Filter Background";
  ui_tooltip = "Filters the game color beneath the circle outline";
> = 0;

uniform float f_circleInnerOutlineGlow <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = MAX_CIRCLE_OUTLINE_THICKNESS/100;
  ui_label = "Inner Outline Glow";
  ui_tooltip = "Controls how many outline glow pixels (inside of the circle)\nshould be rendered around the sharp outline.";
  ui_spacing = 2;
> = 2.0;
#define CircleInnerOutlineGlow (max(f_circleInnerOutlineGlow, 0))

uniform float f_circleInnerOutlineSharpness <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = MAX_CIRCLE_OUTLINE_THICKNESS/100;
  ui_label = "Inner Outline Sharpness";
  ui_tooltip = "Controls how many outline pixels (inside of the circle)\nshould be rendered as 100% opaque.";
> = 1.0;
#define CircleInnerOutlineSharpness (min(max(f_circleInnerOutlineSharpness, 0), CircleInnerOutlineGlow))

uniform float f_circleOuterOutlineGlow <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = MAX_CIRCLE_OUTLINE_THICKNESS/100;
  ui_label = "Outer Outline Glow";
  ui_tooltip = "Controls how many outline glow pixels (outside of the circle)\nshould be rendered around the sharp outline.";
> = 2.0;
#define CircleOuterOutlineGlow (max(f_circleOuterOutlineGlow, 0))

uniform float f_circleOuterOutlineSharpness <
  ui_category = CATEGORY_RSFX_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = MAX_CIRCLE_OUTLINE_THICKNESS/100;
  ui_label = "Outer Outline Sharpness";
  ui_tooltip = "Controls how many outline pixels (outside of the circle)\nshould be rendered as 100% opaque.";
> = 1.0;
#define CircleOuterOutlineSharpness (min(max(f_circleOuterOutlineSharpness, 0), CircleOuterOutlineGlow))



/**
 * Input States
 */

// Mouse button to toggle between overlays
#ifndef RETICLE_ZOOM_BUTTON
#define RETICLE_ZOOM_BUTTON 1
#endif

// Keycode to toggle between overlays
#ifndef RETICLE_ZOOM_KEY
#define RETICLE_ZOOM_KEY 0x00
#endif

uniform bool rightMouseDown <
  source = "mousebutton";
  keycode = RETICLE_ZOOM_BUTTON;
  toggle = false;
>;

uniform bool rightMouseToggle <
  source = "mousebutton";
  keycode = RETICLE_ZOOM_BUTTON;
  mode = "toggle";
  toggle = false;
>;

uniform bool keyDown <
  source = "key";
  keycode = RETICLE_ZOOM_KEY;
  toggle = false;
>;

uniform bool keyToggle <
  source = "key";
  keycode = RETICLE_ZOOM_KEY;
  mode = "toggle";
  toggle = false;
>;



/**
 * Helpers
 */

#ifndef CROSS_OUTLINE_GLOW_CURVE
  #define CROSS_OUTLINE_GLOW_CURVE CROSS_OUTLINE_GLOW_BEZIER_CUBIC_PRESET_1

#endif

// https://cubic-bezier.com/#.06,1.2,0,.9
#define CROSS_OUTLINE_GLOW_BEZIER_CUBIC_PRESET_1(intensity) (cubicBezier(float2(.06, 1.2), float2(0, .9), intensity))

// https://cubic-bezier.com/#.42,0,.58,1  Stock Ease-In-Out
#define CROSS_OUTLINE_GLOW_BEZIER_CUBIC_PRESET_2(intensity) (cubicBezier(float2(.25, .75), float2(.25, .75), intensity))

#define CROSS_OUTLINE_GLOW_RADIAL(intensity) (lerp(0.0, CrossOutlineGlowOpacity, intensity))

float2 cubicBezier(float2 p1, float2 p2, float i) {
  float x = pow(1 - i, 3) * 0 +
    3 * i * pow(1 - i, 2) * p1.x +
    3 * pow(i, 2) * (1 - i) * p2.x +
    pow(i, 3) * 1;
  float y = pow(1 - i, 3) * 0 +
    3 * i * pow(1 - i, 2) * p1.y +
    3 * pow(i, 2) * (1 - i) * p2.y +
    pow(i, 3) * 1;
  return float2(x, y);
}

#define BareCrossWidth (CrossWidth + CrossGap)
#define BareCrossHeight (CrossHeight + CrossGap)

#define EULER (0.57721566490153286061)

#define XOR(a, b) ((a) && !(b) || !(a) && (b))

#define invertSaturate(x) (1.0 - saturate((x)))
#define manhattanDistance(p1, p2) (abs(p1.x - p2.x) + abs(p1.y - p2.y))

#ifdef __DEBUG__
uniform int random1 < source = "random"; min = 0; max = 255; >;
uniform int random2 < source = "random"; min = 0; max = 255; >;
uniform int random3 < source = "random"; min = 0; max = 255; >;
#endif



/**
 * Shader Functions
 */

// Circle Crosshair Shader
void drawCircleReticle(float distCenter, out float4 draw, inout float drawOpacity, inout float4 drawBackgroundMask) {
  draw = float4(CircleColor, 1.0);
  drawOpacity = CircleOpacity * ReticleOpacity;
  drawBackgroundMask = CircleFilter * ReticleOpacity;
  
  bool isReticlePixel = int(round(
    max(CircleThickness - abs(distCenter - (CircleGapRadius + CircleThickness / 2.0)), 0) / CircleThickness
  )) == 1;

  if (!isReticlePixel) {
    drawOpacity = 0;
    drawBackgroundMask = 0;
  }

  if (CircleOutlineEnabled && !isReticlePixel) {

    float bareCrosshairInnerRadius = CircleGapRadius;
    float bareCrosshairOuterRadius = CircleGapRadius + CircleThickness;

    float outerOutlineFullRadius = bareCrosshairOuterRadius + CircleOuterOutlineGlow;
    float outerOutlineSharpRadius = bareCrosshairOuterRadius + CircleOuterOutlineSharpness;

    float innerOutlineFullRadius = bareCrosshairInnerRadius - CircleInnerOutlineGlow;
    float innerOutlineSharpRadius = bareCrosshairInnerRadius - CircleInnerOutlineSharpness;

    draw = float4(CircleOutlineColor, 1.0);

    if (distCenter < outerOutlineFullRadius && distCenter > CircleGapRadius) {
      float glowIntensity = invertSaturate((outerOutlineFullRadius - distCenter) / (CircleOuterOutlineGlow - CircleOuterOutlineSharpness));
      drawOpacity = distCenter < outerOutlineSharpRadius
        ? CircleOutlineOpacity * ReticleOpacity
        : (CircleOutlineGlowEnabled ? lerp(CircleOuterOutlineGlowOpacity, 0.0, glowIntensity) : 0.0) * ReticleOpacity;
      drawBackgroundMask = lerp(CircleOutlineFilter * ReticleOpacity, 0.0, glowIntensity);
    } else if (distCenter > innerOutlineFullRadius && distCenter < bareCrosshairInnerRadius) {
      float glowIntensity = saturate((innerOutlineFullRadius - distCenter) / (CircleInnerOutlineGlow - CircleInnerOutlineSharpness));
      drawOpacity = distCenter > innerOutlineSharpRadius
        ? CircleOutlineOpacity * ReticleOpacity
        : (CircleOutlineGlowEnabled ? lerp(CircleInnerOutlineGlowOpacity, 0.0, glowIntensity) : 0.0) * ReticleOpacity;
      
      drawBackgroundMask = lerp(CircleOutlineFilter * ReticleOpacity, 0.0, glowIntensity);
    }
  }
}




// Dot Crosshair Shader
void drawDotReticle(int distX, int distY, int distCenter, out float4 draw, inout float drawOpacity, inout float4 drawBackgroundMask) {
  
if (
  // Dot: Circle
  (DotType == 0 && distCenter <= DotSize) ||
  // Dot: Square
  (DotType == 1 && abs(distX) <= (DotSize - 1) && abs(distY) <= (DotSize - 1))
  ) {
    draw = float4(DotColor, 1.0);
    drawOpacity = DotOpacity * ReticleOpacity;
    drawBackgroundMask = DotFilter * ReticleOpacity;
  }
}

// Cross Crosshair Shader
void drawCrossReticle(int distX, int distY, out float4 draw, inout float drawOpacity, inout float4 drawBackgroundMask) {
  int absDistX = abs(distX);
  int absDistY = abs(distY);

  draw = float4(CrossColor, 1.0);
  drawOpacity = CrossOpacity * ReticleOpacity;
  drawBackgroundMask = CrossFilter * ReticleOpacity;

  if (absDistX < absDistY) { // Vertical pixel

    bool isReticlePixel = int(round(min(
      max((CrossThickness * 2.0) - absDistX, 0) / max(CrossThickness * 2.0, 1),
      max(BareCrossHeight - absDistY, 0)
    ))) == 1;

    // T-shape: don't render pixels above the gap
    if (ReticleDrawTshape && distY >= CrossGap) {
      drawOpacity = 0;
      drawBackgroundMask = 0;
      return;
    }

    // Check if we should (not) render a reticle pixel
    if (absDistY < CrossGap || !isReticlePixel) {
      drawOpacity = 0;
      drawBackgroundMask = 0;
    }

    // Check if we should render an outline pixel
    if (CrossOutlineEnabled && !isReticlePixel && absDistY >= CrossGap) {

      // Pixel distance from the bare crosshair (w/o the outline)
      int bareCrossDistX = absDistX - CrossThickness;
      int bareCrossDistY = absDistY - BareCrossHeight;

      // Pixel distance from the sharp outline
      int sharpOutlineDistX = bareCrossDistX - CrossOutlineSharpness;
      int sharpOutlineDistY = bareCrossDistY - CrossOutlineSharpness;

      draw = float4(CrossOutlineColor, 1.0);

      #ifdef __DEBUG__
      if (sharpOutlineDistX == 0 && sharpOutlineDistY == 0) {
        draw = float4(random1/255.0, random2/255.0, random3/255.0, 1);
        return draw;
      }
      #endif

      float2 relativePos = float2(max(bareCrossDistX, 0), max(bareCrossDistY, 0));
      float dist = distance(relativePos, float2(0, 0));
      if (dist < CrossOutlineSharpness) {
        drawOpacity = ReticleOpacity;
        drawBackgroundMask = CrossOutlineFilter * ReticleOpacity;
        drawOpacity *= CrossOutlineOpacity * ReticleOpacity;
      } else if (dist < (CrossOutlineSharpness + CrossOutlineGlow)) {
        float glowIntensity = saturate(1.0 - ((dist - CrossOutlineSharpness) / float(CrossOutlineGlow)));
        
        drawOpacity = ReticleOpacity * (CrossOutlineGlowEnabled ? saturate(CROSS_OUTLINE_GLOW_CURVE(glowIntensity).x) : 0.0);
        drawBackgroundMask = CrossOutlineFilter * drawOpacity;
        
        drawOpacity *= CrossOutlineGlowOpacity;
      }

    }

  } else { // Horizontal pixel

    bool isReticlePixel = int(round(min(
      max((CrossThickness * 2.0) - absDistY, 0) / max(CrossThickness * 2.0, 1),
      max(BareCrossWidth - absDistX, 0)
    ))) == 1;

    // Check if we should (not) render a reticle pixel
    if (absDistX < CrossGap || !isReticlePixel) {
      drawOpacity = 0;
      drawBackgroundMask = 0;
    }

    // Check if we should render an outline pixel
    if (CrossOutlineEnabled && !isReticlePixel && absDistX >= CrossGap) {

      // Pixel distance from the bare crosshair (w/o the outline)
      int bareCrossDistX = absDistX - BareCrossWidth;
      int bareCrossDistY = absDistY - CrossThickness;

      // Pixel distance from the sharp outline
      int sharpOutlineDistX = bareCrossDistX - CrossOutlineSharpness;
      int sharpOutlineDistY = bareCrossDistY - CrossOutlineSharpness;

      draw = float4(CrossOutlineColor, 1.0);

      #ifdef __DEBUG__
      if (sharpOutlineDistX == 0 && sharpOutlineDistY == 0) {
        draw = float4(random1/255.0, random2/255.0, random3/255.0, 1);
        return draw;
      }
      #endif

      float2 relativePos = float2(max(bareCrossDistX, 0), max(bareCrossDistY, 0));
      float dist = distance(relativePos, float2(0, 0));
      if (dist < CrossOutlineSharpness) {
        drawOpacity = ReticleOpacity;
        drawBackgroundMask = CrossOutlineFilter * ReticleOpacity;
        drawOpacity *= CrossOutlineOpacity * ReticleOpacity;
      } else if (dist < (CrossOutlineSharpness + CrossOutlineGlow)) {
        float glowIntensity = saturate(1.0 - ((dist - CrossOutlineSharpness) / float(CrossOutlineGlow)));
        drawOpacity = ReticleOpacity * (CrossOutlineGlowEnabled ? saturate(CROSS_OUTLINE_GLOW_CURVE(glowIntensity).x) : 0.0);
        drawBackgroundMask = CrossOutlineFilter * drawOpacity;
        drawOpacity *= CrossOutlineGlowOpacity;
      }

    }

  }
}



/**
 * ReShade Functions
 */

void PS_RSFX(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 passColor : SV_Target) {
  passColor = tex2D(ReShade::BackBuffer, texcoord);
  // Don't render if RMB hiding is activated
  if (!(XOR(HideOnRMB == 0 && rightMouseDown || HideOnRMB == 1 && rightMouseToggle, InvertHideOnRMB))) {

    float2 center = float2((BUFFER_WIDTH / 2) + OffsetX, (BUFFER_HEIGHT / 2) + OffsetY);

    int distX = center.x - pos.x;
    int distY = center.y - pos.y;
    float distCenter = distance(center, float2(pos.x, pos.y));
    
    

    float4 draw1;
    float draw1Opacity = 0;
    float draw1BackgroundMask = 0;
    
    float4 draw2;
    float draw2Opacity = 0;
    float draw2BackgroundMask = 0;
    
    float4 draw3;
    float draw3Opacity = 0;
    float draw3BackgroundMask = 0;
    
    
    if (ReticleDrawCircle) 
      { drawCircleReticle(distCenter, draw1, draw1Opacity, draw1BackgroundMask); };
    if (ReticleDrawTshape || ReticleDrawCross) 
      { drawCrossReticle(distX, distY, draw2, draw2Opacity, draw2BackgroundMask); };
    if (ReticleDrawDot) 
      { drawDotReticle(distX, distY, distCenter, draw3, draw3Opacity, draw3BackgroundMask); };
    
    
    if ( max(max(draw1BackgroundMask, draw2BackgroundMask), draw3BackgroundMask) > 0 ) { 
      passColor = lerp(passColor, 1-passColor, max(max(draw1BackgroundMask, draw2BackgroundMask), draw3BackgroundMask));
    }
    
    passColor = lerp(lerp(lerp(passColor, draw1, draw1Opacity), draw2, draw2Opacity), draw3, draw3Opacity);
    
  }
}

technique RSFX {
  pass RSFXpass {
    VertexShader = PostProcessVS;
    PixelShader = PS_RSFX;
  }
}
