package com.cyl.classifymenu.example.tageditor

import android.content.Context
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.RectF
import android.graphics.drawable.Drawable
import org.json.JSONObject
import java.util.Locale

/**
 * The tag editor example's resources: its iOS bundle (`Example-Swift/CYLTagEditorExample/CYLTagEditorExample.bundle`),
 * whose `<language>.lproj` folders are this app's assets: `Localizable.strings`, `tags.json`, `fold-styles.*`.
 */
object CYLTagEditorLocalization {
    private val tables = HashMap<String, Map<String, String>>()

    /**
     * The `.lproj` of the current language: zh-Hans, zh-Hant or en.
     */
    fun language(): String {
        val locale = Locale.getDefault()
        if (locale.language != "zh") return "en"
        val traditional = locale.script == "Hant" || locale.country in setOf("TW", "HK", "MO")
        return if (traditional) "zh-Hant" else "zh-Hans"
    }

    /**
     * The path of a file of the current language's folder.
     */
    fun path(file: String) = "CYLTagEditorExample.bundle/${language()}.lproj/$file"

    fun table(context: Context): Map<String, String> = tables.getOrPut(language()) {
        val text = try {
            context.assets.open(path("Localizable.strings")).use { it.readBytes().toString(Charsets.UTF_8) }
        } catch (e: Exception) {
            ""
        }
        val entry = Regex("\"((?:[^\"\\\\]|\\\\.)*)\"\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"\\s*;")
        entry.findAll(text.replace(Regex("/\\*.*?\\*/", RegexOption.DOT_MATCHES_ALL), "")).associate {
            it.groupValues[1].replace("\\\"", "\"") to it.groupValues[2].replace("\\\"", "\"").replace("\\n", "\n")
        }
    }
}

/**
 * `CYLTagEditorLocalizedString`: the example's lookup (its own bundle, never the library's); `%@` takes `arguments`.
 */
fun CYLTagEditorLocalizedString(context: Context, key: String, vararg arguments: Any): String {
    val format = CYLTagEditorLocalization.table(context)[key] ?: key
    if (arguments.isEmpty()) return format
    return String.format(format.replace("%@", "%s"), *arguments)
}

/**
 * `CYLTagGroup` of the example: a title and its tags (the fold style demos' sections).
 */
data class CYLTagEditorGroup(val title: String, val tags: List<String>)

/**
 * `CYLTagData`: `tags.json` of the current language.
 */
data class CYLTagData(val version: Int, val tags: List<String>, val recentTags: List<String>, val selectedTags: List<String>, val groups: List<CYLTagEditorGroup>?) {
    companion object {
        fun decode(text: String): CYLTagData {
            val json = JSONObject(text)
            fun strings(key: String) = json.optJSONArray(key)?.let { array -> (0 until array.length()).map { array.getString(it) } } ?: emptyList()
            val groups = json.optJSONArray("groups")?.let { array ->
                (0 until array.length()).map { index ->
                    val group = array.getJSONObject(index)
                    val tags = group.getJSONArray("tags")
                    CYLTagEditorGroup(group.getString("title"), (0 until tags.length()).map { tags.getString(it) })
                }
            }
            return CYLTagData(json.optInt("version"), strings("tags"), strings("recentTags"), strings("selectedTags"), groups)
        }

        /**
         * `+bundled`.
         */
        fun bundled(context: Context): CYLTagData =
            decode(context.assets.open(CYLTagEditorLocalization.path("tags.json")).use { it.readBytes().toString(Charsets.UTF_8) })
    }
}

/**
 * `CYLTagStore`: the tags (without duplicates), the recently used ones (at most `recentLimit`), search, create,
 * delete and mark as used.
 */
class CYLTagStore(tags: List<String>, recentTags: List<String> = emptyList(), val recentLimit: Int = 8) {
    var tags: List<String> = tags.distinct()
        private set
    var recentTags: List<String> = recentTags.filter { it in this.tags }.distinct().take(recentLimit)
        private set

    companion object {
        fun bundled(context: Context): CYLTagStore = CYLTagData.bundled(context).let { CYLTagStore(it.tags, it.recentTags) }

        /**
         * `+normalizedName:`: trimmed.
         */
        fun normalizedName(name: String) = name.trim()
    }

    fun contains(tag: String) = tag in tags

    /**
     * The tags containing `query` (case and width insensitive), the ones starting with it first.
     */
    fun tagsMatching(query: String): List<String> {
        val q = normalizedName(query)
        if (q.isEmpty()) return emptyList()
        fun fold(text: String) = java.text.Normalizer.normalize(text, java.text.Normalizer.Form.NFKD).replace(Regex("\\p{M}"), "").lowercase()
        val folded = fold(q)
        val matches = tags.filter { fold(it).contains(folded) }
        val prefixed = matches.filter { fold(it).startsWith(folded) }
        return prefixed + matches.filter { it !in prefixed }
    }

    fun canCreate(name: String): Boolean = normalizedName(name).let { it.isNotEmpty() && !contains(it) }

    fun createTag(name: String): String? {
        val tag = normalizedName(name)
        if (tag.isEmpty()) return null
        if (!contains(tag)) tags = tags + tag
        return tag
    }

    fun deleteTag(tag: String) {
        tags = tags - tag
        recentTags = recentTags - tag
    }

    fun markUsed(used: List<String>) {
        val known = used.filter(::contains)
        recentTags = (known + recentTags.filter { it !in known }).take(recentLimit)
    }
}

/**
 * The SF Symbols the iOS example uses, drawn simply (line icons in the paint's color).
 */
class CYLSymbolDrawable(private val name: String, private val sizeDp: Float, density: Float) : Drawable() {
    private val px = (sizeDp * density).toInt()
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = 1.6f * density; strokeCap = Paint.Cap.ROUND; strokeJoin = Paint.Join.ROUND; color = 0xFF000000.toInt() }

    override fun getIntrinsicWidth() = px
    override fun getIntrinsicHeight() = px

    override fun draw(canvas: Canvas) {
        val b = bounds
        val w = b.width().toFloat()
        val h = b.height().toFloat()
        val x = b.left.toFloat()
        val y = b.top.toFloat()
        fun r(l: Float, t: Float, rr: Float, bb: Float) = RectF(x + w * l, y + h * t, x + w * rr, y + h * bb)
        val path = Path()
        when (name) {
            "plus" -> { path.moveTo(x + w / 2, y + h * 0.15f); path.lineTo(x + w / 2, y + h * 0.85f); path.moveTo(x + w * 0.15f, y + h / 2); path.lineTo(x + w * 0.85f, y + h / 2) }
            "chevron.left" -> { path.moveTo(x + w * 0.62f, y + h * 0.2f); path.lineTo(x + w * 0.32f, y + h / 2); path.lineTo(x + w * 0.62f, y + h * 0.8f) }
            "hand.thumbsup.fill", "hand.thumbsdown.fill" -> {
                canvas.save()
                if (name == "hand.thumbsdown.fill") canvas.rotate(180f, x + w / 2, y + h / 2)
                paint.style = Paint.Style.FILL
                canvas.drawRoundRect(r(0.1f, 0.45f, 0.3f, 0.9f), w * 0.04f, w * 0.04f, paint)
                path.moveTo(x + w * 0.36f, y + h * 0.45f); path.lineTo(x + w * 0.5f, y + h * 0.1f); path.lineTo(x + w * 0.6f, y + h * 0.15f)
                path.lineTo(x + w * 0.56f, y + h * 0.4f); path.lineTo(x + w * 0.88f, y + h * 0.42f); path.lineTo(x + w * 0.8f, y + h * 0.9f); path.lineTo(x + w * 0.36f, y + h * 0.9f); path.close()
                canvas.drawPath(path, paint)
                paint.style = Paint.Style.STROKE
                canvas.restore()
                return
            }
            "hand.raised.fill" -> {
                paint.style = Paint.Style.FILL
                for (i in 0..3) canvas.drawRoundRect(r(0.2f + i * 0.16f, 0.12f + (if (i == 0 || i == 3) 0.08f else 0f), 0.32f + i * 0.16f, 0.6f), w * 0.06f, w * 0.06f, paint)
                canvas.drawRoundRect(r(0.2f, 0.45f, 0.8f, 0.9f), w * 0.15f, w * 0.15f, paint)
                paint.style = Paint.Style.STROKE
                return
            }
            "person.crop.circle" -> { canvas.drawCircle(x + w / 2, y + h / 2, w * 0.42f, paint); canvas.drawCircle(x + w / 2, y + h * 0.4f, w * 0.14f, paint); canvas.drawArc(r(0.25f, 0.58f, 0.75f, 0.95f), 200f, 140f, false, paint) }
            "chevron.right" -> { path.moveTo(x + w * 0.38f, y + h * 0.2f); path.lineTo(x + w * 0.68f, y + h / 2); path.lineTo(x + w * 0.38f, y + h * 0.8f) }
            "star.bubble" -> { canvas.drawRoundRect(r(0.1f, 0.12f, 0.9f, 0.75f), w * 0.15f, w * 0.15f, paint); path.moveTo(x + w * 0.3f, y + h * 0.75f); path.lineTo(x + w * 0.25f, y + h * 0.92f); path.lineTo(x + w * 0.45f, y + h * 0.75f); canvas.drawCircle(x + w / 2, y + h * 0.43f, w * 0.1f, paint) }
            "briefcase" -> { canvas.drawRoundRect(r(0.1f, 0.3f, 0.9f, 0.85f), w * 0.08f, w * 0.08f, paint); canvas.drawRoundRect(r(0.35f, 0.15f, 0.65f, 0.3f), w * 0.05f, w * 0.05f, paint) }
            "heart" -> { path.moveTo(x + w / 2, y + h * 0.85f); path.cubicTo(x - w * 0.1f, y + h * 0.4f, x + w * 0.25f, y + h * 0.05f, x + w / 2, y + h * 0.32f); path.cubicTo(x + w * 0.75f, y + h * 0.05f, x + w * 1.1f, y + h * 0.4f, x + w / 2, y + h * 0.85f) }
            "square.grid.2x2" -> { canvas.drawRect(r(0.12f, 0.12f, 0.45f, 0.45f), paint); canvas.drawRect(r(0.55f, 0.12f, 0.88f, 0.45f), paint); canvas.drawRect(r(0.12f, 0.55f, 0.45f, 0.88f), paint); canvas.drawRect(r(0.55f, 0.55f, 0.88f, 0.88f), paint) }
            "chevron.down.square" -> { canvas.drawRoundRect(r(0.1f, 0.1f, 0.9f, 0.9f), w * 0.15f, w * 0.15f, paint); path.moveTo(x + w * 0.3f, y + h * 0.42f); path.lineTo(x + w / 2, y + h * 0.62f); path.lineTo(x + w * 0.7f, y + h * 0.42f) }
            "arrow.left.square" -> { canvas.drawRoundRect(r(0.1f, 0.1f, 0.9f, 0.9f), w * 0.15f, w * 0.15f, paint); path.moveTo(x + w * 0.7f, y + h / 2); path.lineTo(x + w * 0.3f, y + h / 2); path.moveTo(x + w * 0.45f, y + h * 0.35f); path.lineTo(x + w * 0.3f, y + h / 2); path.lineTo(x + w * 0.45f, y + h * 0.65f) }
            "text.aligncenter" -> { for ((i, half) in listOf(0.38f, 0.25f, 0.38f, 0.2f).withIndex()) { val yy = y + h * (0.22f + i * 0.19f); path.moveTo(x + w * (0.5f - half), yy); path.lineTo(x + w * (0.5f + half), yy) } }
            "tag" -> { path.moveTo(x + w * 0.12f, y + h * 0.12f); path.lineTo(x + w * 0.5f, y + h * 0.12f); path.lineTo(x + w * 0.88f, y + h * 0.5f); path.lineTo(x + w * 0.5f, y + h * 0.88f); path.lineTo(x + w * 0.12f, y + h * 0.5f); path.close(); canvas.drawCircle(x + w * 0.32f, y + h * 0.32f, w * 0.06f, paint) }
            "person.2" -> { canvas.drawCircle(x + w * 0.35f, y + h * 0.35f, w * 0.13f, paint); canvas.drawCircle(x + w * 0.68f, y + h * 0.38f, w * 0.11f, paint); canvas.drawArc(r(0.1f, 0.55f, 0.6f, 1.05f), 180f, 180f, false, paint); canvas.drawArc(r(0.48f, 0.58f, 0.9f, 1.0f), 180f, 180f, false, paint) }
            "leaf" -> { path.moveTo(x + w * 0.2f, y + h * 0.85f); path.cubicTo(x + w * 0.1f, y + h * 0.3f, x + w * 0.5f, y + h * 0.1f, x + w * 0.88f, y + h * 0.12f); path.cubicTo(x + w * 0.9f, y + h * 0.55f, x + w * 0.6f, y + h * 0.85f, x + w * 0.2f, y + h * 0.85f); path.moveTo(x + w * 0.2f, y + h * 0.85f); path.lineTo(x + w * 0.6f, y + h * 0.45f) }
            else -> canvas.drawCircle(x + w / 2, y + h / 2, w * 0.35f, paint)
        }
        canvas.drawPath(path, paint)
    }

    override fun setAlpha(alpha: Int) { paint.alpha = alpha }
    override fun setColorFilter(colorFilter: ColorFilter?) { paint.colorFilter = colorFilter }
    override fun setTint(tintColor: Int) { paint.color = tintColor; invalidateSelf() }
    @Deprecated("Deprecated in Java")
    override fun getOpacity() = PixelFormat.TRANSLUCENT
}
