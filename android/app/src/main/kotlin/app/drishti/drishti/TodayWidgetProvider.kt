package app.drishti.drishti

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Home-screen widget. The Flutter side pre-computes several days of content
 * (the native side cannot run the astronomy engine), stored as JSON keyed by
 * local date, and this provider simply shows today's entry.
 */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val day = try {
            JSONObject(widgetData.getString("days", "{}") ?: "{}").optJSONObject(today)
        } catch (e: Exception) {
            null
        }

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.today_widget)
            views.setTextViewText(R.id.widget_title, day?.optString("title") ?: "Drishti")
            views.setTextViewText(
                R.id.widget_line1,
                day?.optString("line1") ?: widgetData.getString("fallback", "Open Drishti to refresh"),
            )
            views.setTextViewText(R.id.widget_line2, day?.optString("line2") ?: "")
            views.setTextViewText(R.id.widget_line3, day?.optString("line3") ?: "")

            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context, 0, launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
