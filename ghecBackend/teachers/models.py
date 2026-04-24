from django.db import models
from django.conf import settings

class Teacher(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    tId = models.CharField(max_length=20, primary_key=True)
    full_name = models.CharField(max_length=200)
    t_phone = models.CharField(max_length=15)
    address = models.CharField(max_length=300)
    image = models.ImageField(upload_to='teacher_images/', null=True, blank=True)
    dept = models.CharField(max_length=20, null=True, blank=True)
    joining_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.tId} - {self.full_name}"