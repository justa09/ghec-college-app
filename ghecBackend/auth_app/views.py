from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth import authenticate
from django.views.decorators.csrf import ensure_csrf_cookie
from django.http import JsonResponse
from students.models import Student
from teachers.models import Teacher
from django.views.decorators.csrf import csrf_protect,csrf_exempt
from django.contrib.auth.models import User
from django.contrib.auth import get_user_model


import requests
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model


# ================= 🔐 LOGIN =================cd cd
@api_view(['POST'])
@csrf_protect
def login_api(request):
    username = request.data.get('username', '').strip()
    password = request.data.get('password', '')

    if not username or not password:
        return Response({
            "status": "error",
            "message": "Username and password required"
        }, status=400)

    user = authenticate(username=username, password=password)

    if user is None:
        return Response({
            "status": "error",
            "message": "Invalid credentials"
        }, status=401)

    if user.role == "student":
        try:
            stu = Student.objects.get(user=user)

            image_url = (
                request.build_absolute_uri(stu.image.url)
                if stu.image
                else ""
            )

            return Response({
                "status": "success",
                "role": "student",
                "name": stu.full_name,
                "id": stu.roll_num,
                "image": image_url
            }, status=200)

        except Student.DoesNotExist:
            return Response({
                "status": "error",
                "message": "Student profile not found"
            }, status=404)

    if (
        user.role == "teacher"
        or user.role == "HOD"
        or user.role == "Principal"
        or user.role == "Lect"
        or user.role == "Management"
    ):
        try:
            teacher = Teacher.objects.get(user=user)

            image_url = (
                request.build_absolute_uri(teacher.image.url)
                if teacher.image
                else ""
            )

            return Response({
                "status": "success",
                "role": user.role,
                "name": teacher.full_name,
                "id": teacher.tId,
                "image": image_url
            }, status=200)

        except Teacher.DoesNotExist:
            return Response({
                "status": "error",
                "message": "Teacher profile not found"
            }, status=404)

    return Response({
        "status": "error",
        "message": f"Invalid role: {user.role}"
    }, status=400)


# ================= 🍪 CSRF TOKEN =================
@ensure_csrf_cookie
def csrf_token(request):
    from django.middleware.csrf import get_token

    token = get_token(request)

    return JsonResponse({
        "message": "CSRF cookie set",
        "csrfToken": token,
        "cookie": request.COOKIES.get("csrftoken")
    })





@csrf_exempt
def resetPassword(request):
    if request.method != "POST":
        return JsonResponse({
            "status": False,
            "message": "Only POST requests are accepted"
        })

    userId = request.POST.get("id")

    if not userId:
        return JsonResponse({
            "status": False,
            "message": "User ID is required"
        })

    User = get_user_model()

    try:
        user = User.objects.get(username=userId)

        if user.role == "student":
            phone = Student.objects.get(
                roll_num=userId
            ).parent_phone
        else:
            phone = Teacher.objects.get(
                tId=userId
            ).t_phone

    except (User.DoesNotExist, Student.DoesNotExist,
            Teacher.DoesNotExist):
        return JsonResponse({
            "status": False,
            "message": "User or phone record not found"
        })

    mobile = "".join(filter(str.isdigit, str(phone)))

    if len(mobile) == 11 and mobile.startswith("0"):
        mobile = mobile[1:]

    if len(mobile) == 10:
        mobile = "91" + mobile

    if len(mobile) != 12 or not mobile.startswith("91"):
        return JsonResponse({
            "status": False,
            "message": "Invalid phone number in Database"
        })

    try:
        response = requests.post(
            "https://api.msg91.com/api/v5/widget/sendOtp",
            headers={
                "authkey": settings.MSG91_AUTH_KEY,
                "content-type": "application/json"
            },
            json={
                "widgetId": settings.MSG91_WIDGET_ID,
                "identifier": mobile
            },
            timeout=15
        )

        result = response.json()
        print("MSG91 WIDGET RESPONSE:", response.status_code, result)

        if response.status_code == 200 and result.get("type") == "success":
            return JsonResponse({
                "status": True,
                "message": f"OTP Sent to **{phone[-3:]}",
                "reqId": result.get("message")
            })

        return JsonResponse({
            "status": False,
            "message": result.get("message", "OTP sending failed")
        })

    except (requests.RequestException, ValueError) as e:
        print("MSG91 ERROR:", str(e))
        return JsonResponse({
            "status": False,
            "message": "Unable to connect to OTP service"
        })


@csrf_exempt
def updateNewPassword(request):

    if request.method != "POST":
        return JsonResponse({
            "status": False,
            "message": "Only POST requests are allowed!"
        })

    userId = request.POST.get('userid', '').strip()
    newPassw = request.POST.get('newPassword', '')

    # Check empty fields
    if not userId or not newPassw:
        return JsonResponse({
            "status": False,
            "message": "User ID and new password are required!"
        })

    User = get_user_model()

    try:
        # Find user using username
        user = User.objects.get(username=userId)

        # Update password securely
        user.set_password(newPassw)
        user.save()

        print("PASSWORD UPDATED SUCCESSFULLY FOR:", userId)

        return JsonResponse({
            "status": True,
            "message": "Password updated successfully!"
        })

    except User.DoesNotExist:

        return JsonResponse({
            "status": False,
            "message": "User not found!"
        })

    except Exception as e:

        print("UPDATE PASSWORD ERROR:", str(e))

        return JsonResponse({
            "status": False,
            "message": "Unable to update password!"
        })