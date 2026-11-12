package com.cyl.classifymenu

import android.content.Context
import android.content.res.Resources
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import kotlin.math.max

/**
 * `CYLTagCreateCell`: the "+ New tag" item: an outlined tag with a plus; it shows the typed name ("+ New tag "name"").
 */
class CYLTagCreateCell @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : CYLTagListCell(context, attrs) {

    /** `-configureWithName:style:enabled:`. */
    fun configureWithName(name: String?, style: CYLMenuStyle, enabled: Boolean) {
        configureWithTitle(titleForName(name), plusImage(), null, null, style, false, enabled)
        cyl_accessibilityIdentifier = CYLTagCreateItemAccessibilityIdentifier
    }

    companion object {
        /** `+plusImage`. */
        @JvmStatic
        fun plusImage(): Drawable = CYLMenuImage("cyl_tag_plus") ?: CYLMenuIconDrawable(CYLMenuIconDrawable.Kind.PLUS)

        /** `+titleForName:`: "New tag", or "New tag "name"" (localized). */
        @JvmStatic
        fun titleForName(name: String?): String {
            if (name.isNullOrEmpty()) return CYLMenuLocalizedString("CYLMenuNewTag", "Creates a tag")
            return String.format(CYLMenuLocalizedString("CYLMenuNewTagNamed", "Creates a tag with this name").replace("%@", "%s"), name)
        }

        /** `+styleWithStyle:`: `style` outlined: the list's background, a separator-colored border, secondary text. */
        @JvmStatic
        fun styleWithStyle(style: CYLMenuStyle): CYLMenuStyle {
            val outlined = style.copy()
            val normal = outlined.normalAppearance
            normal.backgroundColor = style.backgroundColor
            normal.borderColor = Color.argb(73, 60, 60, 67)
            normal.borderWidth = max(1f / max(1f, Resources.getSystem().displayMetrics.density), 1f)
            normal.textColor = Color.argb(153, 60, 60, 67)
            outlined.setIconColor(Color.argb(76, 60, 60, 67), CYLControlState.NORMAL)
            outlined.setTitleTextAttributes(null, null, CYLControlState.NORMAL)
            outlined.imagePlacement = CYLTagImagePlacement.CYLTagImagePlacementLeading
            if (outlined.imageSize == CYLSize.ZERO) outlined.imageSize = CYLSize(14f, 14f)
            return outlined
        }
    }
}
