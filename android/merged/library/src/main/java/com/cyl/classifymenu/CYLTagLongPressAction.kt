package com.cyl.classifymenu

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.util.TypedValue
import android.view.Gravity
import android.view.ViewGroup
import android.widget.TextView
import kotlin.math.max
import kotlin.math.min

// What a long press on an item does (`CYLTagListView.longPressAction`). The list owns the gesture; an action owns the
// behavior: reordering, a callout with the item's subtitle, or the host's own code. The events
// (`menuDidLongPressItemAtIndexPath`, `tagLongPressHandler`) stay notifications: the built-in actions report them, and
// they never change the behavior. The same contract as HarmonyOS (docs/tag-long-press-action.md).
//
//   list.longPressAction = CYLTagLongPressActions.first(listOf(CYLTagLongPressActions.reorder, CYLTagLongPressActions.callout))
//   list.longPressAction = CYLTagLongPressActions.handler { host, indexPath -> host.showCallout("My text", indexPath) }
//
// The default is `first(reorder, report)`: reordering where the list can reorder, else the long press is reported,
// exactly as before this API existed.

/** The list as an action sees it: the primitives the built-in and the custom actions are made of. */
interface CYLTagLongPressHost {
    /** The item's subtitle from the data source (`menuSubtitleForItemAtIndexPath`), or null. */
    fun subtitleForItem(indexPath: CYLIndexPath): String?

    /** Shows a small callout with an arrow, pointing at the item, with [text]. Replaces a callout that is showing. */
    fun showCallout(text: String, indexPath: CYLIndexPath)

    /** Hides the callout. */
    fun dismissCallout()

    /** Whether the list can reorder this item now. */
    fun canReorderItem(indexPath: CYLIndexPath): Boolean

    /** Starts reordering with the item picked up (a selected item's drag is reported). */
    fun beginReordering(indexPath: CYLIndexPath)

    /** Ends reordering: the data source moves the item to [destination] when [moved]; a press that did not move is reported as a long press. */
    fun endReordering(destination: CYLIndexPath?, moved: Boolean)

    /** Ends reordering without moving anything. */
    fun cancelReordering()

    /** Reports a long press: `menuDidLongPressItemAtIndexPath`, then `tagLongPressHandler`. */
    fun reportLongPress(indexPath: CYLIndexPath)
}

/** What a long press on an item does. */
interface CYLTagLongPressAction {
    /** Whether this action takes the press on this item (reorder: the list can reorder; callout: the item has a subtitle). */
    fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean

    /** The press was recognized. Returns true to follow the finger; [end] or [cancel] then arrive. */
    fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean

    /** The finger lifted over [destination] (null: outside the list); [moved] tells whether it left the item. */
    fun end(host: CYLTagLongPressHost, destination: CYLIndexPath?, moved: Boolean) {}

    /** The gesture was cancelled. */
    fun cancel(host: CYLTagLongPressHost) {}
}

private class CYLTagReorderAction : CYLTagLongPressAction {
    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = host.canReorderItem(indexPath)

    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean {
        host.beginReordering(indexPath)
        return true
    }

    override fun end(host: CYLTagLongPressHost, destination: CYLIndexPath?, moved: Boolean) = host.endReordering(destination, moved)

    override fun cancel(host: CYLTagLongPressHost) = host.cancelReordering()
}

private class CYLTagReportAction : CYLTagLongPressAction {
    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = true

    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean {
        host.reportLongPress(indexPath)
        return false
    }
}

private class CYLTagCalloutAction : CYLTagLongPressAction {
    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = !host.subtitleForItem(indexPath).isNullOrEmpty()

    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean {
        host.subtitleForItem(indexPath)?.takeIf { it.isNotEmpty() }?.let { host.showCallout(it, indexPath) }
        host.reportLongPress(indexPath)
        return false
    }
}

private class CYLTagNoneAction : CYLTagLongPressAction {
    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = true

    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = false
}

private class CYLTagHandlerAction(private val handler: (CYLTagLongPressHost, CYLIndexPath) -> Unit) : CYLTagLongPressAction {
    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = true

    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean {
        handler(host, indexPath)
        return false
    }
}

/** The first action of a list whose `canBegin` passes takes the press; it also receives the end and the cancel. */
private class CYLTagFirstAction(private val actions: List<CYLTagLongPressAction>) : CYLTagLongPressAction {
    private var chosen: CYLTagLongPressAction? = null

    override fun canBegin(host: CYLTagLongPressHost, indexPath: CYLIndexPath) = actions.any { it.canBegin(host, indexPath) }

    override fun begin(host: CYLTagLongPressHost, indexPath: CYLIndexPath): Boolean {
        chosen = null
        for (action in actions) {
            if (!action.canBegin(host, indexPath)) continue
            val follows = action.begin(host, indexPath)
            chosen = if (follows) action else null
            return follows
        }
        return false
    }

    override fun end(host: CYLTagLongPressHost, destination: CYLIndexPath?, moved: Boolean) {
        val action = chosen
        chosen = null
        action?.end(host, destination, moved)
    }

    override fun cancel(host: CYLTagLongPressHost) {
        val action = chosen
        chosen = null
        action?.cancel(host)
    }
}

/** The built-in long-press actions, and the ways to combine them or write your own. */
object CYLTagLongPressActions {
    /** Picks the item up to reorder it, where the list can reorder (the data source moves the item). */
    @JvmField
    val reorder: CYLTagLongPressAction = CYLTagReorderAction()

    /** Only reports the long press (`menuDidLongPressItemAtIndexPath`, `tagLongPressHandler`). */
    @JvmField
    val report: CYLTagLongPressAction = CYLTagReportAction()

    /** Shows the item's subtitle in a callout with an arrow, where the item has one, and reports the long press. */
    @JvmField
    val callout: CYLTagLongPressAction = CYLTagCalloutAction()

    /** Does nothing (not even a report). */
    @JvmField
    val none: CYLTagLongPressAction = CYLTagNoneAction()

    /** Runs [handler] instead of a built-in behavior; it can use the host's primitives, such as `showCallout`. */
    @JvmStatic
    fun handler(handler: (CYLTagLongPressHost, CYLIndexPath) -> Unit): CYLTagLongPressAction = CYLTagHandlerAction(handler)

    /** The first of [actions] that can begin takes the press, as "reorder where editable, a callout elsewhere". */
    @JvmStatic
    fun first(actions: List<CYLTagLongPressAction>): CYLTagLongPressAction = CYLTagFirstAction(actions)

    /** The default of a list: `first(reorder, report)`, the behavior before this API existed. */
    @JvmStatic
    fun makeDefault(): CYLTagLongPressAction = CYLTagFirstAction(listOf(reorder, report))
}

/**
 * The callout of a long press: a small bubble with an arrow pointing at the tag. [arrowCenter] is the arrow's x in the
 * bubble; [arrowUp] puts the arrow on the top edge (the bubble is below the tag), else on the bottom edge.
 */
internal class CYLTagCalloutBubble(context: Context, text: String) : androidx.appcompat.widget.AppCompatTextView(context) {
    private val density = resources.displayMetrics.density
    /** Dark mode: a dark bubble with a light text, as the system's callouts. */
    private val night = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
        android.content.res.Configuration.UI_MODE_NIGHT_YES
    private val arrowHeight = 7 * density
    private val arrowHalfWidth = 7 * density
    var arrowCenter: Float = 0f
        set(value) { field = value; invalidate() }
    var arrowUp: Boolean = false
        set(value) {
            field = value
            updatePadding()
            invalidate()
        }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = if (night) 0xFF2C2C2E.toInt() else 0xFFFFFFFF.toInt() }
    private val shadow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = 0x00000000
        setShadowLayer(6 * density, 0f, 2 * density, 0x33000000)
    }

    init {
        this.text = text
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        setTextColor(if (night) 0xFFFFFFFF.toInt() else 0xFF000000.toInt())
        maxLines = 3
        ellipsize = android.text.TextUtils.TruncateAt.END
        maxWidth = (240 * density).toInt()
        gravity = Gravity.CENTER
        setLayerType(LAYER_TYPE_SOFTWARE, null)
        layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        updatePadding()
    }

    companion object {
        /**
         * Whether the callout goes below the tag (arrow up), as iOS `CYLTagCalloutView.placesBelow`. Above first (the contract); below
         * when it does not fit above, or when it would cover the header (the section header above a first-row tag) and it fits below;
         * above when neither side is free of the header and below does not fit. Pure: all values are in screen pixels.
         * [height] is the bubble view's height, which includes [shadowMargin] on both sides; the drawn bubble is smaller.
         */
        @JvmStatic
        fun placesBelow(targetTop: Int, targetBottom: Int, height: Int, safeTop: Int, bottomLimit: Int, shadowMargin: Int,
                        headerTop: Int?, headerBottom: Int?): Boolean {
            val aboveTop = targetTop - height
            if (aboveTop < safeTop) return true
            if (headerTop == null || headerBottom == null || headerBottom <= headerTop) return false
            // The bubble is clamped horizontally and may be wider than the header's text: compare the vertical ranges only.
            val coversHeader = headerTop < targetTop && headerBottom > aboveTop + 2 * shadowMargin
            val fitsBelow = targetBottom + height - 2 * shadowMargin <= bottomLimit
            return coversHeader && fitsBelow
        }
    }

    private fun updatePadding() {
        val horizontal = (12 * density).toInt()
        val vertical = (8 * density).toInt()
        val arrow = arrowHeight.toInt()
        // Room around for the shadow, then the bubble's own padding, the arrow's side on top or bottom.
        val margin = (6 * density).toInt()
        setPadding(margin + horizontal, margin + vertical + if (arrowUp) arrow else 0, margin + horizontal,
            margin + vertical + if (arrowUp) 0 else arrow)
    }

    override fun onDraw(canvas: Canvas) {
        val margin = 6 * density
        val body = RectF(margin, margin + if (arrowUp) arrowHeight else 0f, width - margin,
            height - margin - if (arrowUp) 0f else arrowHeight)
        val radius = min(12 * density, body.height() / 2)
        val path = Path().apply { addRoundRect(body, radius, radius, Path.Direction.CW) }
        val center = max(body.left + radius + arrowHalfWidth, min(body.right - radius - arrowHalfWidth, arrowCenter))
        val arrow = Path().apply {
            if (arrowUp) {
                moveTo(center - arrowHalfWidth, body.top)
                lineTo(center, body.top - arrowHeight)
                lineTo(center + arrowHalfWidth, body.top)
            } else {
                moveTo(center - arrowHalfWidth, body.bottom)
                lineTo(center, body.bottom + arrowHeight)
                lineTo(center + arrowHalfWidth, body.bottom)
            }
            close()
        }
        path.op(arrow, Path.Op.UNION)
        canvas.drawPath(path, shadow)
        canvas.drawPath(path, paint)
        super.onDraw(canvas)
    }
}
