from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Attendance
from students.models import Student, Subject

@csrf_exempt
def submit_attendance(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        data = json.loads(request.body)
        attendance_objects = []

        for record in data:
            roll_num = record.get("roll_num")
            subject_id = record.get("subject_id")
            status = record.get("status")
            lecture_no = record.get("lecture_no")
            date = record.get("date")

            if not roll_num or not subject_id:
                continue

            try:
                student = Student.objects.get(roll_num=roll_num)
                subject = Subject.objects.get(subject_id=subject_id)

                if status == "A":
                    p_num = student.parent_phone
                    s_num = student.student_phone
                    name = student.full_name
                    sub_name = subject.sub_name
                    print()
                    print(f"{name} is absent in {sub_name} class | Message sent to Parent: {p_num}")
                    print()
                    print(f"Dear {name}, you are marked Absent in {sub_name} class | SMS to: {s_num}")
                    print()

                attendance_objects.append(
                    Attendance(
                        student=student,
                        subject=subject,
                        status=status,
                        lecture_no=lecture_no,
                        date=date,
                    )
                )

            except Student.DoesNotExist:
                print(f"Student not found for roll: {roll_num}")
                continue
            except Subject.DoesNotExist:
                print(f"Subject not found: {subject_id}")
                continue

        Attendance.objects.bulk_create(attendance_objects)

        return JsonResponse({"message": "Attendance saved"}, status=201)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
def showAttendance(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST request is accepted"}, status=405)

    try:
        data = json.loads(request.body)
        if not isinstance(data, list):
            return JsonResponse({"error": "Expected a list of roll numbers"}, status=400)

        results = []
        for rollnumber in data:
            print(f"Fetching Attendance for {rollnumber}")

            student = Student.objects.filter(roll_num=rollnumber).first()
            if not student:
                results.append({
                    "roll_num": rollnumber,
                    "total_lectures": 0,
                    "total_present": 0,
                    "attendance_percentage": 0,
                    "subjects": []
                })
                continue

            # 🔹 All subjects of the student
            subjects = Subject.objects.filter(attendance__student=student).distinct()
            subject_attendance = []
            total_lectures = 0
            total_present = 0

            for sub in subjects:
                attendances = Attendance.objects.filter(student=student, subject=sub)
                present_count = attendances.filter(status="P").count()
                total_count = attendances.count()
                total_lectures += total_count
                total_present += present_count

                subject_attendance.append({
                    "subject": sub.sub_name,
                    "present": present_count,
                    "total": total_count,
                    "percentage": round((present_count / total_count * 100) if total_count > 0 else 0, 1)
                })

            overall_percentage = round((total_present / total_lectures * 100) if total_lectures > 0 else 0, 1)

            results.append({
                "roll_num": rollnumber,
                "total_lectures": total_lectures,
                "total_present": total_present,
                "attendance_percentage": overall_percentage,
                "subjects": subject_attendance
            })

        return JsonResponse(results, safe=False)

    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON"}, status=400)
    except Exception as e:
        print(f"Error: {e}")
        return JsonResponse({"error": "Something went wrong"}, status=500)