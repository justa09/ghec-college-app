from rest_framework.decorators import api_view
from rest_framework.response import Response
from students.models import Student
from teachers.models import Teacher


@api_view(['POST'])
def login_api(request):

    UserId = request.data.get('username')
    passw = request.data.get('password')
    usertype = request.data.get('usertype')

    if not UserId:
        return Response({"status": "error", "message": "Invalid credentials"})

    if usertype == "student":
        try:
            stu = Student.objects.get(roll_num=UserId)

            image_url = None
            if stu.image:
                image_url = request.build_absolute_uri(stu.image.url)
            else:
                image_url = ""

            return Response({
                "status": "success",
                "username": stu.full_name,
                "rollNo": stu.roll_num,
                "image": image_url
            })

        except Student.DoesNotExist:
            return Response({"status": "error", "message": "Student not found"})


    elif usertype == "teacher":
        try:
            teacher = Teacher.objects.get(tId=UserId)

            image_url = None
            if teacher.image:
                image_url = request.build_absolute_uri(teacher.image.url)
            else :
                image_url =""

            return Response({
                "status": "success",
                "username": teacher.full_name,
                "rollNo": teacher.tId,
                "image": image_url
            })

        except Teacher.DoesNotExist:
            return Response({"status": "error", "message": "Teacher not found"})


    return Response({"status": "error", "message": "Invalid usertype"})