# -*- coding: utf-8 -*-

from odoo import api, models, fields, _ # type: ignore
from datetime import date, timedelta # type: ignore
from odoo.exceptions import ValidationError, UserError # type: ignore
import logging
_logger = logging.getLogger(__name__)


class HrEmployeeBase(models.AbstractModel):
    _inherit = 'hr.employee.base'
