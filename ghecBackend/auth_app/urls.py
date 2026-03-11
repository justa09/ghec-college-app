from django.urls import path
from .views import login_api  # <-- direct function import

urlpatterns = [
    path("login/", login_api, name="login"),  # name optional, par better practice
]