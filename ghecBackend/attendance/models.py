from django.db import models
from students.models import Student,Subject

class Attendance(models.Model):
    id = models.AutoField(primary_key=True)
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    subject = models.ForeignKey('students.Subject', on_delete=models.CASCADE)
    date = models.DateField()
    status = models.CharField(max_length=1)
    lecture_no = models.IntegerField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.student} - {self.subject} - {self.date}"