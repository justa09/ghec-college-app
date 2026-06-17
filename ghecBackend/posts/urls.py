from django.urls import path
from .views import *
urlpatterns = [
    path('create-post/', create_post, name='create_post'),
    path('get-posts/', get_posts, name='get_posts'),
]