{
    'name': 'Hospital Management UTN',
    'version': '17.0.1.0.0',
    'sequence': -1200,
    'category': 'Healthcare',
    'summary': 'Modulo de ejemplo para la gestión de un hospital',
    'description': 'Descripción larga del módulo hospitalario',
    'author': 'Ivo',
    'depends': ['base'],
    'data': [
        'views/menu.xml',
        'views/patient_view.xml',
        'security/ir.model.access.csv',
    ],
    'installable': True,
    'auto_install': False,
    'application': True,
    'license': 'LGPL-3',
}