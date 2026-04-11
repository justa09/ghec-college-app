
from django.urls import path
from .views import create_post, get_posts

urlpatterns = [
    path('create-post/', create_post),
    path('get-posts/', get_posts),
]
