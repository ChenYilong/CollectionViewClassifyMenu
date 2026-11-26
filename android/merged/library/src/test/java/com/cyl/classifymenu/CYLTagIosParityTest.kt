package com.cyl.classifymenu

import android.graphics.Color
import android.content.res.Resources
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode

/**
 * The iOS parity items of the tag: the callout that avoids the section header (`CYLTagCalloutBubble.placesBelow`), the badge dot
 * and capsule (`CYLTag.badgeDotImage`, `badgeImageWidth`) and the public "is set" flags of `CYLTagAppearance`.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
@GraphicsMode(GraphicsMode.Mode.NATIVE)
class CYLTagIosParityTest {

    private val density = Resources.getSystem().displayMetrics.density

    // MARK: The callout avoids the section header

    private val shadow = 6
    private val bubbleHeight = 100
    private val displayBottom = 2000

    private fun below(targetTop: Int, headerTop: Int?, headerBottom: Int?, safeTop: Int = 0) =
        CYLTagCalloutBubble.placesBelow(targetTop, targetTop + 40, bubbleHeight, safeTop, displayBottom, shadow, headerTop, headerBottom)

    @Test
    fun theCalloutIsAboveWithNoHeader() {
        assertFalse(below(targetTop = 500, headerTop = null, headerBottom = null))
    }

    @Test
    fun theCalloutGoesBelowWhenThereIsNoRoomAbove() {
        assertTrue(below(targetTop = 50, headerTop = null, headerBottom = null))
    }

    @Test
    fun theCalloutGoesBelowWhenItWouldCoverTheHeader() {
        // The header is the row right above the tag: the bubble above the tag would cover it.
        assertTrue(below(targetTop = 500, headerTop = 450, headerBottom = 494))
    }

    @Test
    fun theCalloutStaysAboveWhenTheHeaderIsFarAbove() {
        assertFalse(below(targetTop = 500, headerTop = 100, headerBottom = 144))
    }

    @Test
    fun theCalloutStaysAboveWhenTheHeaderCoveringIsUnavoidableAndBelowDoesNotFit() {
        val tooLow = CYLTagCalloutBubble.placesBelow(1950, 1990, bubbleHeight, 0, displayBottom, shadow, 1900, 1944)
        assertFalse(tooLow)
    }

    @Test
    fun anEmptyHeaderIsIgnored() {
        assertFalse(below(targetTop = 500, headerTop = 480, headerBottom = 480))
    }

    // MARK: The badge dot and the capsule

    @Test
    fun aDotIsEightDpWideCenteredInTheCanvasInSystemRedByDefault() {
        val canvas = 18f
        val image = CYLTag.badgeDotImage(null, canvas) as CYLBadgeDrawable
        val side = (canvas * density).toInt()
        assertEquals(side, image.bitmap.width)
        assertEquals(side, image.bitmap.height)
        assertEquals(Color.rgb(255, 59, 48), image.bitmap.getPixel(side / 2, side / 2))
        val dotRadius = (CYLTag.BADGE_DOT_DIAMETER * density / 2).toInt()
        assertEquals("outside the dot is clear", 0, image.bitmap.getPixel(side / 2 + dotRadius + 2, side / 2))
        assertEquals(CYLMenuLocalizedString("CYLTagBadgeDot", "A badge shown as a dot"), image.accessibilityLabel)
    }

    @Test
    fun aDotUsesTheBadgeColorAndIsAtMostTheCanvas() {
        val image = CYLTag.badgeDotImage(Color.GREEN, 4f) as CYLBadgeDrawable
        assertEquals(Color.GREEN, image.bitmap.getPixel(image.bitmap.width / 2, image.bitmap.height / 2))
        assertEquals((4f * density).toInt(), image.bitmap.width)
    }

    @Test
    fun anEmptyBadgeTextOfATagMakesTheDotImageAndNullMakesNone() {
        val dot = CYLTag.tagWithTitle("a").also { it.badgeText = "" }
        val none = CYLTag.tagWithTitle("b")
        val source = CYLTagDataSource(listOf(dot, none))
        val dotImage = source.menuImageForItemAtIndexPath(CYLIndexPath(0, 0))
        assertNotNull(dotImage)
        assertEquals(CYLMenuLocalizedString("CYLTagBadgeDot", "A badge shown as a dot"), (dotImage as CYLBadgeDrawable).accessibilityLabel)
        assertNull(source.menuImageForItemAtIndexPath(CYLIndexPath(1, 0)))
    }

    @Test
    fun aShortBadgeTextIsACircleAndALongOneIsAWiderCapsule() {
        val diameter = 18f
        assertEquals(diameter, CYLTag.badgeImageWidth("1", diameter), 0f)
        val wide = CYLTag.badgeImageWidth("99+ new", diameter)
        assertTrue(wide > diameter)
        val image = CYLTag.badgeImageWithText("99+ new", null, diameter) as CYLBadgeDrawable
        assertEquals((diameter * density).toInt(), image.bitmap.height)
        assertTrue("the image is as wide as badgeImageWidth", image.bitmap.width >= (diameter * density).toInt())
        assertEquals((wide * density).toInt(), image.bitmap.width)
        assertEquals("99+ new", image.accessibilityLabel)
        val circle = CYLTag.badgeImageWithText("1", null, diameter) as CYLBadgeDrawable
        assertEquals(circle.bitmap.height, circle.bitmap.width)
    }

    @Test
    fun theIconSlotFollowsTheCapsuleWidthAndKeepsTheStyleHeight() {
        val style = CYLMenuStyle().also { it.imageSize = CYLSize(18f, 18f) }
        val capsule = CYLTag.badgeImageWithText("99+ new", null, 18f)
        val slot = CYLTagButton.iconSizeForImage(capsule, false, style)
        assertEquals(18f, slot.height, 0f)
        assertTrue(slot.width > 18f)
        val circle = CYLTag.badgeImageWithText("1", null, 18f)
        assertEquals(CYLSize(18f, 18f), CYLTagButton.iconSizeForImage(circle, false, style))
    }

    // MARK: The "is set" flags

    @Test
    fun theColorFlagsFollowTheSettersResetsAndClone() {
        val appearance = CYLTagAppearance()
        assertFalse(appearance.isBackgroundColorSet)
        assertFalse(appearance.isTextColorSet)
        assertFalse(appearance.isIconColorSet)
        appearance.backgroundColor = Color.RED
        appearance.textColor = Color.BLUE
        appearance.iconColor = Color.GREEN
        assertTrue(appearance.isBackgroundColorSet)
        assertTrue(appearance.isTextColorSet)
        assertTrue(appearance.isIconColorSet)
        val copy = appearance.clone()
        assertTrue(copy.isBackgroundColorSet && copy.isTextColorSet && copy.isIconColorSet)
        appearance.resetBackgroundColor()
        appearance.resetTextColor()
        appearance.iconColor = null
        assertFalse(appearance.isBackgroundColorSet)
        assertFalse(appearance.isTextColorSet)
        assertFalse(appearance.isIconColorSet)
    }

    @Test
    fun theBorderFlagsAreSeparateAndTheDefaultBorderIsNotExplicit() {
        val appearance = CYLTagAppearance()
        assertFalse(appearance.isBorderColorSet)
        assertFalse(appearance.isBorderWidthSet)
        appearance.borderWidth = 2f
        assertFalse(appearance.isBorderColorSet)
        assertTrue(appearance.isBorderWidthSet)
        assertFalse("a width alone is not an explicit border", appearance.hasExplicitBorder)
        appearance.borderColor = Color.RED
        assertTrue(appearance.isBorderColorSet)
        assertTrue(appearance.hasExplicitBorder)
        assertTrue(appearance.clone().isBorderWidthSet)
        appearance.reset()
        assertFalse(appearance.isBorderColorSet)
        assertFalse(appearance.isBorderWidthSet)
    }

    @Test
    fun theGlassBorderIsTheExplicitColorWithItsEffectiveWidthElseNone() {
        val appearance = CYLTagAppearance()
        appearance.setDefaultBorder(Color.GRAY, 1f)
        assertNull("the built-in border is dropped under glass", appearance.glassBorderColor)
        assertEquals(0f, appearance.glassBorderWidth, 0f)
        appearance.borderWidth = 3f
        assertNull("a width alone draws none", appearance.glassBorderColor)
        assertEquals(0f, appearance.glassBorderWidth, 0f)
        appearance.borderColor = Color.RED
        assertEquals(Color.RED, appearance.glassBorderColor)
        assertEquals(3f, appearance.glassBorderWidth, 0f)
        appearance.borderColor = null
        assertNull(appearance.glassBorderColor)
        assertEquals(0f, appearance.glassBorderWidth, 0f)
    }
}
