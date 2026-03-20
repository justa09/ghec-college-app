from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Student, ProfileUpdateRequest
from teachers.models import Teacher


# 🔹 1. Create Request (Student)
@csrf_exempt
def create_update_request(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        data = json.loads(request.body)

        roll_no = data.get("roll_no")
        field_name = data.get("field_name")
        new_value = data.get("new_value")

        if not roll_no or not field_name or not new_value:
            return JsonResponse({"error": "Missing fields"}, status=400)

        student = Student.objects.filter(roll_num=roll_no).first()
        if not student:
            return JsonResponse({"error": "Student not found"}, status=404)

        # 🔥 old value fetch
        old_value = getattr(student, field_name, None)

        # 🔥 create request
        req = ProfileUpdateRequest.objects.create(
            student=student,
            field_name=field_name,
            old_value=str(old_value),
            new_value=str(new_value),
        )

        return JsonResponse({
            "message": "Request submitted",
            "request_id": req.id
        })

    except Exception as e:
        print(e)
        return JsonResponse({"error": "Something went wrong"}, status=500)


# 🔹 2. Get Requests (Admin)
def get_all_requests(request):
    print("ok bhai pounch gya..!")
    requests = ProfileUpdateRequest.objects.filter(status="pending")
   

    data = []
    for r in requests:
        data.append({
    "id": r.id,
    "student": r.student.full_name,
    "roll_no": r.student.roll_num,
    "field_name": r.field_name,
    "old_value": r.old_value,
    "new_value": r.new_value,
    "status": r.status,
})
        print(r)

    return JsonResponse(data, safe=False)


# 🔹 3. Approve / Reject Request
@csrf_exempt
def handle_request(request, request_id):
    print("Babe ye handle_Request hai")

    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        data = json.loads(request.body)
        action = data.get("action")  # approve / reject
        teacher_id = data.get("teacher_id")

        req = ProfileUpdateRequest.objects.select_related("student").filter(id=request_id).first()
        if not req:
            return JsonResponse({"error": "Request not found"}, status=404)

        if req.status != "pending":
            return JsonResponse({"error": "Already processed"}, status=400)

        teacher = Teacher.objects.filter(tId=teacher_id).first()

        if action == "approve":
            student = req.student
            student_num = Student.student_phone
          

            # 🔥 update actual student field
            setattr(student,req.field_name, req.new_value)
            student.save()

            req.status = "approved"
            

        elif action == "reject":
            req.status = "rejected"

        else:
            return JsonResponse({"error": "Invalid action"}, status=400)

        req.reviewed_by = teacher
        req.save()

        return JsonResponse({"message": f"Request {req.status}"})

    except Exception as e:
        print(e)
        return JsonResponse({"error": "Something went wrong"}, status=500)