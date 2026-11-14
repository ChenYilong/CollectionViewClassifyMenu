package com.cyl.classifymenu

import android.graphics.drawable.Drawable
import java.util.Locale

/**
 * The core's localized strings and images: the same `<language>.lproj/CYLClassifyMenu.strings` tables as iOS
 * (`CYLClassifyMenuResources.bundle`), packaged as Java resources under `CYLClassifyMenuResources/`, so they load
 * without a Context. `preferredLanguage` overrides the system language; a missing key falls back to English, then to
 * the key itself.
 */
object CYLMenuResources {

    private const val BUNDLE = "CYLClassifyMenuResources"
    private const val TABLE = "CYLClassifyMenu"
    private const val FALLBACK_LANGUAGE = "en"
    private val tables = HashMap<String, Map<String, String>>()

    /** `+bundle`: the resource folder's name in the library's Java resources. */
    @JvmStatic
    fun bundle(): String = BUNDLE

    /**
     * `+imageNamed:`: a drawable of the bundle's images (`CYLClassifyMenuResources/<name>@3x.png`, `@2x` or 1x, copied
     * from the iOS asset catalog), scaled like the iOS image (3x as xxhdpi, 2x as xhdpi, 1x as mdpi); null when missing.
     */
    @JvmStatic
    fun imageNamed(name: String): Drawable? {
        val loader = javaClass.classLoader ?: return null
        for ((suffix, density) in listOf("@3x" to android.util.DisplayMetrics.DENSITY_XXHIGH, "@2x" to android.util.DisplayMetrics.DENSITY_XHIGH, "" to android.util.DisplayMetrics.DENSITY_MEDIUM)) {
            val stream = loader.getResourceAsStream("$BUNDLE/$name$suffix.png") ?: continue
            val bitmap = stream.use { android.graphics.BitmapFactory.decodeStream(it) } ?: continue
            bitmap.density = density
            return android.graphics.drawable.BitmapDrawable(android.content.res.Resources.getSystem(), bitmap)
        }
        return null
    }

    /** `+availableLanguages`, sorted. */
    @JvmStatic
    fun availableLanguages(): List<String> = listOf("en", "zh-Hans", "zh-Hant").filter { table(it).isNotEmpty() }.sorted()

    /** `preferredLanguage`: a language of `availableLanguages()` used instead of the system's; null for the system's. */
    @JvmStatic
    @Volatile
    var preferredLanguage: String? = null

    /** `+currentLanguage`: the preferred language when set, else the system language, else English. */
    @JvmStatic
    fun currentLanguage(): String {
        val available = availableLanguages()
        val preference = preferredLanguage ?: languageTag(Locale.getDefault())
        return match(preference, available) ?: FALLBACK_LANGUAGE
    }

    /** `+localizedStringForKey:`. */
    @JvmStatic
    fun localizedStringForKey(key: String): String = localizedStringForKey(key, currentLanguage())

    /** `+localizedStringForKey:language:`. */
    @JvmStatic
    fun localizedStringForKey(key: String, language: String?): String {
        for (candidate in listOf(language ?: FALLBACK_LANGUAGE, FALLBACK_LANGUAGE)) {
            table(candidate)[key]?.takeIf { it.isNotEmpty() }?.let { return it }
        }
        return key
    }

    private fun languageTag(locale: Locale): String = when {
        locale.language == "zh" && (locale.script == "Hant" || locale.country in setOf("TW", "HK", "MO")) -> "zh-Hant"
        locale.language == "zh" -> "zh-Hans"
        else -> locale.language
    }

    private fun match(preference: String, available: List<String>): String? {
        available.firstOrNull { it.equals(preference, ignoreCase = true) }?.let { return it }
        val tag = when {
            preference.startsWith("zh-Hant", true) || preference.startsWith("zh-TW", true) || preference.startsWith("zh-HK", true) -> "zh-Hant"
            preference.startsWith("zh", true) -> "zh-Hans"
            else -> preference.substringBefore('-').substringBefore('_')
        }
        return available.firstOrNull { it.equals(tag, ignoreCase = true) }
    }

    @Synchronized
    private fun table(language: String): Map<String, String> = tables.getOrPut(language) {
        val stream = CYLMenuResources::class.java.classLoader?.getResourceAsStream("$BUNDLE/$language.lproj/$TABLE.strings")
            ?: return@getOrPut emptyMap()
        parseStrings(stream.use { it.readBytes().toString(Charsets.UTF_8) })
    }

    /** Parses an Apple `.strings` file: `"key" = "value";` lines, comments allowed. */
    internal fun parseStrings(text: String): Map<String, String> {
        val result = LinkedHashMap<String, String>()
        val withoutComments = text.replace(Regex("/\\*.*?\\*/", RegexOption.DOT_MATCHES_ALL), "").replace(Regex("(?m)^\\s*//.*$"), "")
        val entry = Regex("\"((?:[^\"\\\\]|\\\\.)*)\"\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"\\s*;")
        for (match in entry.findAll(withoutComments)) {
            result[unescape(match.groupValues[1])] = unescape(match.groupValues[2])
        }
        return result
    }

    private fun unescape(value: String): String {
        val out = StringBuilder()
        var i = 0
        while (i < value.length) {
            val c = value[i]
            if (c == '\\' && i + 1 < value.length) {
                when (val next = value[i + 1]) {
                    'n' -> out.append('\n')
                    't' -> out.append('\t')
                    '"' -> out.append('"')
                    '\\' -> out.append('\\')
                    'U', 'u' -> {
                        val hex = value.substring(i + 2, minOf(i + 6, value.length))
                        hex.toIntOrNull(16)?.let { out.append(it.toChar()); i += 4 } ?: out.append(next)
                    }
                    else -> out.append(next)
                }
                i += 2
                continue
            }
            out.append(c)
            i++
        }
        return out.toString()
    }
}

/**
 * `CYLMenuLocalizedStringForKey` / the macro `CYLMenuLocalizedString(key, comment)`.
 */
fun CYLMenuLocalizedStringForKey(key: String): String = CYLMenuResources.localizedStringForKey(key)

/**
 * The macro `CYLMenuLocalizedString(key, comment)`: the comment only documents the key.
 */
@Suppress("UNUSED_PARAMETER")
fun CYLMenuLocalizedString(key: String, comment: String? = null): String = CYLMenuResources.localizedStringForKey(key)

/**
 * The macro `CYLMenuImage(name)`.
 */
fun CYLMenuImage(name: String): Drawable? = CYLMenuResources.imageNamed(name)
