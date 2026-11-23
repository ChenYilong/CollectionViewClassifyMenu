package com.cyl.classifymenu

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.view.View
import android.view.accessibility.AccessibilityNodeInfo
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/**
 * `CYLTagButton` on its own, as the one icon + title + animated icon component (a search bar item, a placeholder's
 * icon): the icon above or below the title, the badge, the convenience constructors (iOS `CYLTagButtonTests`).
 */
@RunWith(RobolectricTestRunner::class)
class CYLTagButtonStandaloneTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()

    private fun icon(): Drawable = BitmapDrawable(context.resources, Bitmap.createBitmap(28, 28, Bitmap.Config.ARGB_8888))

    private fun layOut(button: CYLTagButton, widthDp: Float, heightDp: Float) {
        val density = context.resources.displayMetrics.density
        val width = (widthDp * density).toInt()
        val height = (heightDp * density).toInt()
        button.measure(View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY))
        button.layout(0, 0, width, height)
    }

    /** The tag is the host of the engine's player: it never lets the view play on selection (the Android view defaults to false, iOS to true). */
    @Test
    fun theTagDrivesItsOwnPlaybackAndTheViewNeverPlaysOnSelection() {
        val button = CYLTagButton(context, "Tag", icon())
        assertEquals(false, button.drivesAnimationPlayback)
        val token = button.animationRestartToken
        button.isSelected = true
        assertEquals(false, button.drivesAnimationPlayback)
        assertEquals("selecting does not restart", token, button.animationRestartToken)
    }

    @Test
    fun theIconCanBeAboveOrBelowTheTitle() {
        assertEquals(2, CYLTagImagePlacement.CYLTagImagePlacementTop.ordinal)
        assertEquals(3, CYLTagImagePlacement.CYLTagImagePlacementBottom.ordinal)
        assertEquals("existing values keep their place", 1, CYLTagImagePlacement.CYLTagImagePlacementTrailing.ordinal)
        val style = CYLMenuStyle()
        style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTop
        style.imageSize = CYLSize(24f, 24f)
        style.imageTitleSpacing = 4f
        val insets = style.normalAppearance.contentInsets
        assertTrue("the icon slot and the spacing are part of the height",
            CYLTagButton.heightForStyle(style) >= 24f + 4f + insets.top + insets.bottom)
        val titleWidth = kotlin.math.ceil(CYLTagButton.textWidth("Messages", style.titleFontForState(CYLControlState.NORMAL)))
        assertEquals("the wider of the two, not their sum",
            kotlin.math.ceil(maxOf(titleWidth, 24f) + insets.left + insets.right),
            CYLTagButton.widthForTitle("Messages", CYLSize(24f, 24f), style), 1f)
        val button = CYLTagButton(context, "Messages", icon())
        button.style = style
        val height = CYLTagButton.heightForStyle(style)
        layOut(button, 120f, height)
        val density = context.resources.displayMetrics.density
        assertTrue("the title below the icon", button.titleLabel.top >= button.imageView.bottom)
        assertEquals("imageTitleSpacing between them", 4f, (button.titleLabel.top - button.imageView.bottom) / density, 1f)
        assertEquals("the icon is centered", 60f * density, (button.imageView.left + button.imageView.right) / 2f, density)

        style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementBottom
        button.style = style
        layOut(button, 120f, height)
        assertTrue("the icon below the title", button.imageView.top >= button.titleLabel.bottom)
    }

    @Test
    fun iconOnlyAndTitleOnlyReserveNoSpacing() {
        val style = CYLMenuStyle()
        val insets = style.normalAppearance.contentInsets
        assertEquals(style.imageSize.width + insets.left + insets.right,
            CYLTagButton.widthForTitle(null, style.imageSize, style), 0.5f)
        style.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementTop
        assertEquals("a lone title has no icon slot", CYLTagButton.heightForTitle("Home", CYLSize.ZERO, CYLMenuStyle()),
            CYLTagButton.heightForTitle("Home", CYLSize.ZERO, style), 0.5f)
    }

    @Test
    fun theBadgeIsADotOrACapsuleAtTheIconsCorner() {
        val button = CYLTagButton(context, "Messages", icon())
        layOut(button, 120f, 40f)
        assertNull(button.badgeValue)
        assertEquals(View.GONE, button.badgeLabel.visibility)
        assertEquals(CYLTagBadgeDefaultColor, button.badgeColor)

        button.badgeValue = ""
        layOut(button, 120f, 40f)
        assertEquals(View.VISIBLE, button.badgeLabel.visibility)
        assertEquals(8f, button.badgeFrame.width, 0.01f)
        assertEquals(8f, button.badgeFrame.height, 0.01f)
        val density = context.resources.displayMetrics.density
        assertEquals("at the icon's trailing edge", button.imageView.right / density, button.badgeFrame.x + 4f, 1f)
        val info = AccessibilityNodeInfo.obtain()
        button.onInitializeAccessibilityNodeInfo(info)
        assertEquals("Messages, " + CYLMenuLocalizedString("CYLTagBadgeDot"), info.contentDescription?.toString())

        button.badgeValue = "99+"
        button.badgeColor = 0xFF0000FF.toInt()
        layOut(button, 120f, 40f)
        assertEquals("99+", button.badgeLabel.text.toString())
        assertTrue("a capsule", button.badgeFrame.width >= button.badgeFrame.height)
        assertTrue("inside the tag", button.badgeFrame.maxX <= 120.5f && button.badgeFrame.y >= 0f)
        val capsule = AccessibilityNodeInfo.obtain()
        button.onInitializeAccessibilityNodeInfo(capsule)
        assertEquals("Messages, 99+", capsule.contentDescription?.toString())
        button.badgeColor = null
        assertEquals("null restores the default", CYLTagBadgeDefaultColor, button.badgeColor)
    }

    @Test
    fun theConvenienceConstructorsMakeAStandaloneTag() {
        val uri = android.net.Uri.parse("file:///no/such/file.json")
        val button = CYLTagButton(context, "Home", icon(), uri)
        assertEquals("Home", button.title)
        assertEquals(uri.toString(), button.animationURL)
        assertNull("a missing file shows the image", button.animationView)
        button.measure(View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED), View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
        assertTrue("it measures itself", button.measuredWidth > 0 && button.measuredHeight > 0)
        assertTrue(button.isClickable)
    }

    /**
     * The display priority of CYLAnimatedItemView, inherited (https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md):
     * a file whose library is not in the app (the core adds none: no Lottie here) shows the static image, with the
     * layout of the image alone, and the playback methods do nothing.
     */
    @Test
    fun withoutTheLibraryTheStaticImageShowsAndPlaybackDoesNothing() {
        val file = java.io.File.createTempFile("cyl-tag", ".json").apply { writeText("{\"v\":\"5.7.0\",\"layers\":[]}") }
        val image = icon()
        val animated = CYLTagButton(context, "Home", image, android.net.Uri.fromFile(file))
        val plain = CYLTagButton(context, "Home", image)
        layOut(animated, 120f, 40f)
        layOut(plain, 120f, 40f)
        assertNull("no Lottie in the core: no animation view", animated.animationView)
        assertSame("the static image, not the placeholder", image, animated.imageView.drawable)
        assertEquals("the layout of the image alone", plain.imageView.left, animated.imageView.left)
        assertEquals(plain.titleLabel.left, animated.titleLabel.left)
        animated.playAnimation()
        animated.restartAnimation()
        animated.stopAnimation()
        animated.showAnimationLastFrame()
        assertEquals("the file is kept, so it plays once the library is added", android.net.Uri.fromFile(file).toString(), animated.animationURL)
        file.delete()
    }

    @Test
    fun anAnimationThatCannotPlayShowsThePlaceholderOnlyWithoutAStaticImage() {
        val missing = android.net.Uri.parse("file:///no/such/file.json")
        val image = icon()
        val withImage = CYLTagButton(context, "Home", image, missing)
        assertSame("a static image wins over the placeholder", image, withImage.imageView.drawable)
        val withoutImage = CYLTagButton(context, "Home", null, missing)
        if (com.cyl.animateditem.CYLAnimatedItemView.defaultPlaceholderImage(context) != null) {
            assertNotNull("no static image: the component's placeholder", withoutImage.imageView.drawable)
        }
        val textOnly = CYLTagButton(context, "Home", null)
        layOut(textOnly, 120f, 40f)
        assertNull("a title without an icon never shows a placeholder", textOnly.imageView.drawable)
    }

    @Test
    fun theDeleteIndicatorIsTheAccessoryWithItsOwnTap() {
        val button = CYLTagButton(context, "Home", icon())
        var tapped = 0
        button.gestureListener = object : com.cyl.animateditem.CYLAnimatedItemGestureListener {
            override fun onAccessoryTapped(item: com.cyl.animateditem.CYLAnimatedItemView) { tapped += 1 }
        }
        button.showsDeleteIndicator = true
        layOut(button, 140f, 40f)
        assertSame(button.deleteIndicatorLabel, button.accessoryView)
        assertEquals(View.VISIBLE, button.deleteIndicatorLabel.visibility)
        button.deleteIndicatorLabel.performClick()
        assertEquals(1, tapped)
        button.showsDeleteIndicator = false
        assertEquals(View.GONE, button.deleteIndicatorLabel.visibility)
    }
}
