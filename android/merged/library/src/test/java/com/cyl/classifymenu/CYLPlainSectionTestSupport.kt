package com.cyl.classifymenu

/**
 * The tag list's section style now defaults to `insetGrouped` (a rounded card, the grouped list background): a test that
 * checks frames, heights, rows, widths or colors of a default-styled list keeps what it tests by opting out with `plain`,
 * the look every such test was written against. A test about the new default builds its list without this call.
 */
internal fun CYLTagListView.usePlainSections() {
    val plain = style!!.copy()
    plain.sectionStyle = CYLSectionStyle.CYLSectionStylePlain
    style = plain
}

/** A style with the section card opted out and nothing else changed: the look the default style had before the flip. */
internal fun CYLMenuStyle.Companion.plainSectionStyle(): CYLMenuStyle = defaultStyle().also { it.sectionStyle = CYLSectionStyle.CYLSectionStylePlain }
