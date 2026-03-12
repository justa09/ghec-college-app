from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth import authenticate
from students.models import Student

@api_view(['POST'])
def login_api(request):
    rollNo = request.data.get('username') 
    passw = request.data.get('password')   
    usertype = request.data.get('usertype')



    if rollNo and passw:
        if usertype =="student":
            try:
                stu = Student.objects.get(roll_num=rollNo)
                iamge = stu.image
                print(iamge)
                image_url = request.build_absolute_uri(stu.image.url)
                return Response({"status":"success",
                                 "username":stu.full_name,
                                 "rollNo":stu.roll_num,
                                 "image":image_url})
            except Student.DoesNotExist:
                return Response({"status":"error","message":"Student not found"})
        elif usertype == 'teacher':
            pass
        return Response({"status":"success","message":"Login successful"})

    else:
        return Response({"status":"error","message":"Invalid credentials"})
    