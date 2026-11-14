package com.cyl.classifymenu.example.menu

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.cyl.classifymenu.example.classify.ClassifyPlacesDatabase
import com.cyl.classifymenu.example.classify.ClassifySQLQuery
import com.cyl.classifymenu.example.tageditor.CYLSymbolDrawable

/**
 * `CYLReviewRating`.
 */
enum class CYLReviewRating { GOOD, NEUTRAL, BAD }

/**
 * `CYLReview`: a review of the product.
 */
data class CYLReview(val user: String, val text: String, val date: String, val sku: String, val rating: CYLReviewRating,
                     val hasPhoto: Boolean, val hasFollowUp: Boolean, val keywords: List<String>)

/**
 * `CYLReviewFilter`: a filter of the review list ("全部", ratings, with photos, follow-ups, keywords).
 */
class CYLReviewFilter(val identifier: String, val name: String, val image: Drawable?, val isKeyword: Boolean, val matches: (CYLReview) -> Boolean)

/**
 * `CYLReviewStore`: the reviews (from the shared example database, `reviews` and `review_keywords`) and the filters.
 */
class CYLReviewStore private constructor(context: Context) {
    val reviews: List<CYLReview>
    val filters: List<CYLReviewFilter>

    init {
        val database = ClassifyPlacesDatabase(context)
        val keywords = database.rowsOf("SELECT review_id, keyword FROM review_keywords ORDER BY rowid").groupBy({ (it["review_id"] as Long).toInt() }, { it["keyword"] as String })
        reviews = database.rowsOf("SELECT * FROM reviews ORDER BY id").map { row ->
            val id = (row["id"] as Long).toInt()
            CYLReview(row["user"] as String, row["text"] as String, row["date"] as String, row["sku"] as String,
                CYLReviewRating.values()[(row["rating"] as Long).toInt()], row["has_photo"] == 1L, row["has_follow_up"] == 1L, keywords[id].orEmpty())
        }
        database.close()
        val density = context.resources.displayMetrics.density
        val orange = Color.rgb(255, 115, 26)
        fun symbol(name: String?, color: Int) = name?.let { CYLSymbolDrawable(it, 13f, density).also { d -> d.setTint(color) } }
        val identifiers = mapOf("全部" to "all", "好评" to "good", "中评" to "neutral", "差评" to "bad", "有图" to "photo", "追加" to "followup")
        fun filter(name: String, symbol: String?, color: Int, keyword: Boolean, matches: (CYLReview) -> Boolean) =
            CYLReviewFilter(if (keyword) "keyword:$name" else identifiers[name] ?: name, name, symbol(symbol, color), keyword, matches)
        filters = listOf(
            filter("全部", null, orange, false) { true },
            filter("好评", "hand.thumbsup.fill", orange, false) { it.rating == CYLReviewRating.GOOD },
            filter("中评", "hand.raised.fill", orange, false) { it.rating == CYLReviewRating.NEUTRAL },
            filter("差评", "hand.thumbsdown.fill", Color.GRAY, false) { it.rating == CYLReviewRating.BAD },
            filter("有图", null, orange, false) { it.hasPhoto },
            filter("追加", null, orange, false) { it.hasFollowUp },
        ) + listOf("手机套不错", "质量不错", "态度不错", "划算", "颜色不错", "背面细节一般").map { keyword -> filter(keyword, null, orange, true) { keyword in it.keywords } }
    }

    companion object {
        @Volatile private var shared: CYLReviewStore? = null

        fun shared(context: Context): CYLReviewStore = shared ?: synchronized(this) { shared ?: CYLReviewStore(context.applicationContext).also { shared = it } }
    }

    fun reviewsMatching(filter: CYLReviewFilter) = reviews.filter(filter.matches)

    fun reviewsMatchingAll(filters: List<CYLReviewFilter>) = reviews.filter { review -> filters.all { it.matches(review) } }

    fun filterWithIdentifier(identifier: String) = filters.firstOrNull { it.identifier == identifier }

    /**
     * The filter's title with its count ("好评(9)"; "全部" alone).
     */
    fun title(context: Context, filter: CYLReviewFilter): String {
        val name = if (filter.isKeyword) filter.name else CYLExampleLocalizedString(context, filter.name)
        return if (filter.name == "全部") name else "$name(${reviewsMatching(filter).size})"
    }
}

/**
 * `CYLReviewFilteringMode`.
 */
enum class CYLReviewFilteringMode { MEMORY, NETWORK, DATABASE }

/**
 * `CYLReviewQuerying`: fetches the reviews matching every filter.
 */
interface CYLReviewQuerying {
    val mode: CYLReviewFilteringMode
    val isLoading: Boolean
    fun fetchReviewsMatching(filters: List<CYLReviewFilter>, completion: (List<CYLReview>) -> Unit)
}

/**
 * `CYLMemoryReviewQuery`: matches in the loaded reviews, at once.
 */
class CYLMemoryReviewQuery(private val store: CYLReviewStore) : CYLReviewQuerying {
    override val mode = CYLReviewFilteringMode.MEMORY
    override val isLoading = false
    override fun fetchReviewsMatching(filters: List<CYLReviewFilter>, completion: (List<CYLReview>) -> Unit) = completion(store.reviewsMatchingAll(filters))
}

/**
 * `CYLNetworkReviewQuery`: sends the filters to a (simulated) server, answers after `latency`; a newer request drops
 * the older one's response.
 */
class CYLNetworkReviewQuery(private val store: CYLReviewStore) : CYLReviewQuerying {
    var latencyMillis = 600L
    override val mode = CYLReviewFilteringMode.NETWORK
    override var isLoading = false
        private set
    var lastRequestURL: Uri? = null
        private set
    var requestCount = 0
        private set
    var droppedResponseCount = 0
        private set
    private val handler = Handler(Looper.getMainLooper())

    companion object {
        fun requestURL(filters: List<CYLReviewFilter>): Uri =
            Uri.parse("https://api.example.com/reviews").buildUpon().apply { filters.forEach { appendQueryParameter("filter", it.identifier) } }.build()
    }

    override fun fetchReviewsMatching(filters: List<CYLReviewFilter>, completion: (List<CYLReview>) -> Unit) {
        val url = requestURL(filters)
        lastRequestURL = url
        requestCount++
        val request = requestCount
        isLoading = true
        handler.postDelayed({
            if (request != requestCount) {
                droppedResponseCount++
                return@postDelayed
            }
            isLoading = false
            // CYLReviewServer: the filters back from the request URL.
            completion(store.reviewsMatchingAll(url.getQueryParameters("filter").mapNotNull(store::filterWithIdentifier)))
        }, latencyMillis)
    }
}

/**
 * `CYLDatabaseReviewQuery`: the filters as SQL on the shared example database (`reviews`, `review_keywords`).
 */
class CYLDatabaseReviewQuery(context: Context, private val store: CYLReviewStore) : CYLReviewQuerying {
    private val database = ClassifyPlacesDatabase(context)
    override val mode = CYLReviewFilteringMode.DATABASE
    override val isLoading = false
    var lastQuery: ClassifySQLQuery? = null
        private set

    companion object {
        fun query(filters: List<CYLReviewFilter>): ClassifySQLQuery {
            val conditions = ArrayList<String>()
            val arguments = ArrayList<String>()
            val ratings = mapOf("good" to CYLReviewRating.GOOD, "neutral" to CYLReviewRating.NEUTRAL, "bad" to CYLReviewRating.BAD)
            for (filter in filters) {
                val rating = ratings[filter.identifier]
                when {
                    rating != null -> { conditions.add("r.rating = ?"); arguments.add(rating.ordinal.toString()) }
                    filter.identifier == "photo" -> conditions.add("r.has_photo = 1")
                    filter.identifier == "followup" -> conditions.add("r.has_follow_up = 1")
                    filter.isKeyword -> { conditions.add("EXISTS (SELECT 1 FROM review_keywords k WHERE k.review_id = r.id AND k.keyword = ?)"); arguments.add(filter.name) }
                }
            }
            var sql = "SELECT r.id FROM reviews r"
            if (conditions.isNotEmpty()) sql += " WHERE " + conditions.joinToString(" AND ")
            return ClassifySQLQuery("$sql ORDER BY r.id", arguments)
        }
    }

    override fun fetchReviewsMatching(filters: List<CYLReviewFilter>, completion: (List<CYLReview>) -> Unit) {
        val query = query(filters)
        lastQuery = query
        val ids = database.rowsOf(query.sql, query.arguments).mapNotNull { (it["id"] as? Long)?.toInt() }
        completion(ids.mapNotNull { store.reviews.getOrNull(it) })
    }
}
