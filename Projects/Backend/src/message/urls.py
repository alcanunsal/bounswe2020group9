from django.urls import path

from .views import Messages, AllMessages, Conversations, GetConversation, Notifications, Reports, AdminComments, AdminUserBan

urlpatterns = [
	path('', Messages.as_view(), name="messages"),
	path('all/', AllMessages.as_view(), name="all-messages"),
	path('conversations/', Conversations.as_view(), name="conversations" ),
	path('<int:id>/', GetConversation.as_view(), name="get-conversation"),
	path('notifications/', Notifications.as_view(), name="notifications" ),
    path('admin/report/', Reports.as_view(), name="admin-report" ),
    path('admin/comment/', AdminComments.as_view(), name="admin-comment" ),
    path('admin/ban/', AdminUserBan.as_view(), name="admin-ban" ),

]
