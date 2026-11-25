package com.cyl.classifymenu.example

import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSectionStyle
import com.cyl.classifymenu.CYLTagListView

/*
 * The library's default section style is the rounded card (`insetGrouped`). The example screens reproduce the iOS demos'
 * flat looks (they draw no card behind their tags), so each of them opts out with `plain`, through these two helpers.
 */

/** This style with the section card opted out (`sectionStyle = plain`); returns it for chaining. */
fun CYLMenuStyle.plainSections(): CYLMenuStyle = apply { sectionStyle = CYLSectionStyle.CYLSectionStylePlain }

/** The list's style with the section card opted out, for a list whose style a configuration file sets. */
fun CYLTagListView.plainSections() {
    style = style!!.copy().plainSections()
}
