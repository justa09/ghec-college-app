from django.urls import path

from .views import *

urlpatterns = [

    path("login/", login_api, name="login"),

    path("csrf/", csrf_token, name="csrf"),
]