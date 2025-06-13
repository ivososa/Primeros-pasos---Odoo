from odoo import api, fields, models

class HospitalPatient(models.Model):
    _name = 'hospital.patient' #Este va a ser el nombre de la tabla en postgres
    _description = 'Patient'
    
    name = fields.Char(string='Name', required=True)
    age = fields.Integer(string='Age', required=True)
    gender = fields.Selection([
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other'),
    ], string='Gender', required=True)

