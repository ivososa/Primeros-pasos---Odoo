# -*- coding: utf-8 -*-
{
    'name': "Configuraciones varias UTN",

    'description': """
        Aplicación central para modificar y personalizar los módulos predeterminados de odoo.
    """,
    'summary': """
        Aplicación central
        """,

    'sequence': -1200,
    'author': "UTN",
    'application': True,
    'installable': True,
    'auto_install': False,

    'category': 'Central',
    'version': '1.0',

    'depends': [
        'web_responsive',
        'mail',
        'calendar',
    ],

    'data': [
    ],
    'demo': [
    ],
    'license': 'LGPL-3',  # Viene por defecto

}
