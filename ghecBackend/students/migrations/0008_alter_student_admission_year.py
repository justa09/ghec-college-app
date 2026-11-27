
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('students', '0007_student_user'),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(
                    sql="""
                        ALTER TABLE students_student
                        ALTER COLUMN admission_year TYPE date
                        USING NULL::date;
                    """,
                    reverse_sql="""
                        ALTER TABLE students_student
                        ALTER COLUMN admission_year TYPE integer
                        USING NULL::integer;
                    """,
                ),
            ],
            state_operations=[
                migrations.AlterField(
                    model_name='student',
                    name='admission_year',
                    field=models.DateField(),
                ),
            ],
        ),
    ]
