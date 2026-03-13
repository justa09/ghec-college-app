from django.db import models

class Teacher(models.Model):
    tId = models.CharField(max_length=20, primary_key=True)
    password = models.CharField(max_length=128)
    full_name = models.CharField(max_length=200)
    t_phone = models.CharField(max_length=15)
    address = models.CharField(max_length=300)
    image = models.ImageField(upload_to='student_images/', null=True, blank=True)
    dept = models.CharField(max_length = 20, null = True , blank = True)
    joining_date = models.DateField(null = True, blank=True)

    def __str__(self):
        return f"{self.tId} - {self.full_name}"

