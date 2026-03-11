from django.db import models

class Student(models.Model):
    roll_num = models.CharField(max_length=20, primary_key=True)
    full_name = models.CharField(max_length=200)
    branch = models.CharField(max_length=30)
    semester = models.IntegerField()
    admission_year = models.IntegerField()
    parent_name = models.CharField(max_length=200)
    parent_phone = models.CharField(max_length=15)  # slightly increased length
    student_phone = models.CharField(max_length=15)
    email = models.EmailField(max_length=50)
    gender = models.CharField(max_length=15)
    date_of_birth = models.DateField()
    address = models.CharField(max_length=300)
    image = models.ImageField(upload_to='student_images/', null=True, blank=True)

    def __str__(self):
        return f"{self.roll_num} - {self.full_name}"


class Subject(models.Model):
    subject_id = models.AutoField(primary_key=True)
    sub_name = models.CharField(max_length=50)
    branch = models.CharField(max_length=50)
    semester = models.IntegerField()

    def __str__(self):
        return self.sub_name