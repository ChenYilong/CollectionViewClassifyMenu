package me.kaede.sample

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import me.kaede.tagview.OnTagClickListener
import me.kaede.tagview.OnTagDeleteListener
import me.kaede.tagview.Tag
import me.kaede.tagview.TagView
import java.util.Random

class MainActivity : AppCompatActivity(), View.OnClickListener {

    private lateinit var tagView: TagView
    private lateinit var editText: EditText
    private lateinit var random: Random

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        findViewById<View>(R.id.tv_add).setOnClickListener(this)
        findViewById<View>(R.id.tv_start_activity).setOnClickListener(this)
        findViewById<View>(R.id.tv_list_activity).setOnClickListener(this)
        findViewById<View>(R.id.tv_recyclerview_activity).setOnClickListener(this)
        editText = findViewById(R.id.edit_tag)
        tagView = findViewById(R.id.tagview)
        // SET LISTENER
        tagView.setOnTagClickListener(OnTagClickListener { position, tag ->
            Toast.makeText(this@MainActivity, "click tag id = " + tag.id + " position = " + position, Toast.LENGTH_SHORT).show()
        })
        tagView.setOnTagDeleteListener(OnTagDeleteListener { position, tag ->
            Toast.makeText(this@MainActivity, "delete tag id = " + tag.id + " position =" + position, Toast.LENGTH_SHORT).show()
        })
        // ADD TAG
        val tags = resources.getStringArray(R.array.continents)
        tagView.addTags(tags)
        random = Random()
        val colors = resources.getStringArray(R.array.colors)
        for (i in 1 until colors.size) {
            val tag = Tag("Colorful Text")
            tag.tagTextColor = Color.parseColor(colors[i])
            tagView.addTag(tag)
        }
        for (item in colors) {
            val tag = Tag("Colorful Background")
            tag.layoutColor = Color.parseColor(item)
            tagView.addTag(tag)
        }
        var tag = Tag("Border")
        tag.layoutBorderSize = 1f
        tagView.addTag(tag)

        tag = Tag("Border")
        tag.layoutBorderSize = 2f
        tag.layoutBorderColor = Color.parseColor(colors[1])
        tagView.addTag(tag)

        tag = Tag("Border")
        tag.layoutBorderSize = 3f
        tag.layoutBorderColor = Color.parseColor(colors[3])
        tagView.addTag(tag)

        tag = Tag("Round Corner")
        tag.radius = 0f
        tagView.addTag(tag)

        tag = Tag("Round Corner")
        tag.radius = 20f
        tagView.addTag(tag)

        tag = Tag("Round Corner")
        tag.radius = 60f
        tagView.addTag(tag)

        tag = Tag("Deletable")
        tag.isDeletable = true
        tagView.addTag(tag)

        tag = Tag("Custom Background")
        tag.tagTextColor = Color.parseColor(colors[0])
        tag.background = ContextCompat.getDrawable(this, R.drawable.bg_tag)
        tagView.addTag(tag)

        tag = Tag("Detail Tag")
        tag.tagTextColor = Color.parseColor("#FFFFFF")
        tag.layoutColor = Color.parseColor("#DDDDDD")
        tag.layoutColorPress = Color.parseColor("#555555")
        // or tag.background = ContextCompat.getDrawable(this, R.drawable.custom_bg)
        tag.radius = 20f
        tag.tagTextSize = 14f
        tag.layoutBorderSize = 1f
        tag.layoutBorderColor = Color.parseColor("#FFFFFF")
        tag.isDeletable = true
        tagView.addTag(tag)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == RESULT_OK) {
            tagView.addTag(Tag("ADD AFTER ACTIVITY RESULT"))
        }
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.action_github) {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/kaedea/")))
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    @Suppress("DEPRECATION")
    override fun onClick(v: View) {
        when (v.id) {
            R.id.tv_add -> {
                var string = "ADD A TAG"
                if (editText.text.toString() != "") string = editText.text.toString()
                val tag = Tag(string)
                var r = random.nextInt(2)
                if (r == 0) tag.isDeletable = true
                r = random.nextInt(5)
                tag.layoutColor = Color.parseColor(resources.getStringArray(R.array.colors)[r])
                tagView.addTag(tag)
            }
            R.id.tv_start_activity -> startActivityForResult(Intent(this, SubActivity::class.java), 0)
            R.id.tv_list_activity -> startActivity(Intent(this, ListViewActivity::class.java))
            R.id.tv_recyclerview_activity -> startActivity(Intent(this, RecyclerViewActivity::class.java))
        }
    }
}
