package com.example.audify

import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "audify/share_story"
    private val deepLinkChannelName = "audify/deep_links"
    private var deepLinkChannel: MethodChannel? = null
    private var latestInviteLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        latestInviteLink = intent?.dataString

        deepLinkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, deepLinkChannelName)
        deepLinkChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                result.success(latestInviteLink)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method != "shareStory") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val platform = call.argument<String>("platform").orEmpty()
            val playlistName = call.argument<String>("playlistName").orEmpty()
            val inviteLink = call.argument<String>("inviteLink").orEmpty()
            val message = call.argument<String>("message").orEmpty()
            val shareLayout = call.argument<String>("shareLayout").orEmpty()
            val inviteAsCollaborator = call.argument<Boolean>("inviteAsCollaborator") ?: false
            val storyImageBytes = call.argument<ByteArray>("storyImageBytes")

            try {
                val imageUri =
                    if (storyImageBytes != null && storyImageBytes.isNotEmpty()) {
                        createStoryImageUriFromBytes(storyImageBytes)
                    } else {
                        createStoryImageUri(
                            playlistName.ifBlank { "Collaborative Playlist" },
                            inviteLink,
                            message.ifBlank { "Join my collaborative playlist on Audify" },
                            shareLayout,
                            inviteAsCollaborator,
                        )
                    }
                val opened = openPlatformComposer(platform, imageUri, message, inviteLink)
                result.success(opened)
            } catch (error: Exception) {
                result.error("share_story_failed", error.message, null)
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        latestInviteLink = intent.dataString
        latestInviteLink?.let { link ->
            deepLinkChannel?.invokeMethod("onLink", link)
        }
    }

    private fun createStoryImageUriFromBytes(bytes: ByteArray): Uri {
        val outDir = File(cacheDir, "story_share")
        outDir.mkdirs()
        val outFile = File(outDir, "audify_selected_share.png")
        FileOutputStream(outFile).use { output ->
            output.write(bytes)
        }

        return FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            outFile,
        )
    }

    private fun createStoryImageUri(
        playlistName: String,
        inviteLink: String,
        message: String,
        shareLayout: String,
        inviteAsCollaborator: Boolean,
    ): Uri {
        val width = 1080
        val height = 1920
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val background = Paint(Paint.ANTI_ALIAS_FLAG)
        background.color = Color.rgb(12, 12, 12)
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), background)

        val accent = Paint(Paint.ANTI_ALIAS_FLAG)
        accent.color = Color.rgb(30, 215, 96)
        canvas.drawCircle(width - 170f, 210f, 90f, accent)
        accent.alpha = 70
        canvas.drawCircle(150f, height - 230f, 160f, accent)

        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG)
        titlePaint.color = Color.WHITE
        titlePaint.textSize = 76f
        titlePaint.typeface = android.graphics.Typeface.create(
            android.graphics.Typeface.DEFAULT,
            android.graphics.Typeface.BOLD,
        )

        val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        bodyPaint.color = Color.rgb(210, 210, 210)
        bodyPaint.textSize = 42f

        val chipPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        chipPaint.color = Color.WHITE

        val chipTextPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        chipTextPaint.color = Color.BLACK
        chipTextPaint.textSize = 42f
        chipTextPaint.typeface = android.graphics.Typeface.create(
            android.graphics.Typeface.DEFAULT,
            android.graphics.Typeface.BOLD,
        )

        if (shareLayout == "artwork") {
            drawArtworkStory(
                canvas,
                width,
                height,
                playlistName,
                message,
                inviteLink,
                titlePaint,
                bodyPaint,
            )
        } else {
            drawPlaylistStory(
                canvas,
                width,
                playlistName,
                message,
                inviteLink,
                inviteAsCollaborator,
                titlePaint,
                bodyPaint,
                chipPaint,
                chipTextPaint,
            )
        }

        val outDir = File(cacheDir, "story_share")
        outDir.mkdirs()
        val outFile = File(outDir, "audify_collab_story.jpg")
        FileOutputStream(outFile).use { output ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 92, output)
        }
        bitmap.recycle()

        return FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            outFile,
        )
    }

    private fun drawPlaylistStory(
        canvas: Canvas,
        width: Int,
        playlistName: String,
        message: String,
        inviteLink: String,
        inviteAsCollaborator: Boolean,
        titlePaint: Paint,
        bodyPaint: Paint,
        chipPaint: Paint,
        chipTextPaint: Paint,
    ) {
        val cardPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        cardPaint.color = Color.rgb(38, 38, 38)
        val cardRect = android.graphics.RectF(90f, 330f, width - 90f, 1360f)
        canvas.drawRoundRect(cardRect, 40f, 40f, cardPaint)

        val coverPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        coverPaint.color = Color.rgb(24, 24, 24)
        val coverRect = android.graphics.RectF(140f, 390f, 390f, 640f)
        canvas.drawRoundRect(coverRect, 18f, 18f, coverPaint)

        val notePaint = Paint(Paint.ANTI_ALIAS_FLAG)
        notePaint.color = Color.rgb(80, 80, 80)
        notePaint.textSize = 132f
        canvas.drawText("♪", 205f, 570f, notePaint)

        drawWrappedText(canvas, playlistName, 450f, 510f, width - 540f, titlePaint, 84f)
        drawWrappedText(canvas, "Playlist by Audify", 450f, 620f, width - 540f, bodyPaint, 54f)
        drawWrappedText(canvas, message, 140f, 820f, width - 280f, bodyPaint, 56f)

        val chipRect = android.graphics.RectF(140f, 1110f, width - 140f, 1230f)
        canvas.drawRoundRect(chipRect, 60f, 60f, chipPaint)
        canvas.drawText(
            if (inviteAsCollaborator) "Join as collaborator" else "Open playlist",
            210f,
            1186f,
            chipTextPaint,
        )

        drawAudifyMark(canvas, width - 270f, 1310f, 36f)

        val linkPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        linkPaint.color = Color.rgb(150, 150, 150)
        linkPaint.textSize = 30f
        drawWrappedText(canvas, inviteLink, 90f, 1540f, width - 180f, linkPaint, 42f)
    }

    private fun drawArtworkStory(
        canvas: Canvas,
        width: Int,
        height: Int,
        playlistName: String,
        message: String,
        inviteLink: String,
        titlePaint: Paint,
        bodyPaint: Paint,
    ) {
        val framePaint = Paint(Paint.ANTI_ALIAS_FLAG)
        framePaint.color = Color.rgb(78, 78, 78)
        val frameRect = android.graphics.RectF(230f, 330f, width - 230f, height - 330f)
        canvas.drawRoundRect(frameRect, 42f, 42f, framePaint)

        val cardPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        cardPaint.color = Color.rgb(18, 18, 18)
        val cardRect = android.graphics.RectF(285f, 500f, width - 285f, 1420f)
        canvas.drawRoundRect(cardRect, 12f, 12f, cardPaint)

        val coverPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        coverPaint.color = Color.rgb(34, 34, 34)
        val coverRect = android.graphics.RectF(335f, 560f, width - 335f, 1040f)
        canvas.drawRoundRect(coverRect, 14f, 14f, coverPaint)

        val notePaint = Paint(Paint.ANTI_ALIAS_FLAG)
        notePaint.color = Color.rgb(80, 80, 80)
        notePaint.textSize = 180f
        canvas.drawText("♪", width / 2f - 68f, 850f, notePaint)

        val smallTitlePaint = Paint(titlePaint)
        smallTitlePaint.textSize = 44f
        drawWrappedText(canvas, playlistName, 335f, 1125f, width - 670f, smallTitlePaint, 54f)
        drawWrappedText(canvas, message, 335f, 1210f, width - 670f, bodyPaint, 48f)
        drawAudifyMark(canvas, 335f, 1345f, 30f)

        val linkPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        linkPaint.color = Color.rgb(150, 150, 150)
        linkPaint.textSize = 28f
        drawWrappedText(canvas, inviteLink, 230f, height - 210f, width - 460f, linkPaint, 38f)
    }

    private fun drawAudifyMark(canvas: Canvas, x: Float, y: Float, size: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = Color.WHITE
        paint.textSize = size
        paint.typeface = android.graphics.Typeface.create(
            android.graphics.Typeface.DEFAULT,
            android.graphics.Typeface.BOLD,
        )
        canvas.drawText("Audify", x, y, paint)
    }

    private fun drawWrappedText(
        canvas: Canvas,
        text: String,
        x: Float,
        startY: Float,
        maxWidth: Float,
        paint: Paint,
        lineHeight: Float,
    ) {
        val words = text.split(" ")
        var line = ""
        var y = startY
        val bounds = Rect()

        for (word in words) {
            val testLine = if (line.isEmpty()) word else "$line $word"
            paint.getTextBounds(testLine, 0, testLine.length, bounds)
            if (bounds.width() > maxWidth && line.isNotEmpty()) {
                canvas.drawText(line, x, y, paint)
                line = word
                y += lineHeight
            } else {
                line = testLine
            }
        }

        if (line.isNotEmpty()) {
            canvas.drawText(line, x, y, paint)
        }
    }

    private fun openPlatformComposer(
        platform: String,
        imageUri: Uri,
        message: String,
        inviteLink: String,
    ): Boolean {
        val intent = when (platform) {
            "instagram" -> Intent("com.instagram.share.ADD_TO_STORY").apply {
                setDataAndType(imageUri, "image/*")
                setPackage("com.instagram.android")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            "facebook" -> Intent("com.facebook.stories.ADD_TO_STORY").apply {
                setDataAndType(imageUri, "image/*")
                setPackage("com.facebook.katana")
                putExtra("com.facebook.platform.extra.APPLICATION_ID", getString(R.string.facebook_app_id))
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            "tiktok" -> Intent(Intent.ACTION_SEND).apply {
                type = "image/*"
                setPackage("com.zhiliaoapp.musically")
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra(Intent.EXTRA_TEXT, message)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            "telegram" -> Intent(Intent.ACTION_SEND).apply {
                type = "image/*"
                setPackage("org.telegram.messenger")
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra(Intent.EXTRA_TEXT, message.ifBlank { inviteLink })
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            "x" -> Intent(Intent.ACTION_SEND).apply {
                type = "image/*"
                setPackage("com.twitter.android")
                putExtra(Intent.EXTRA_STREAM, imageUri)
                putExtra(Intent.EXTRA_TEXT, message.ifBlank { inviteLink })
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            else -> return false
        }

        return try {
            grantUriPermission(intent.`package`, imageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
    }
}
