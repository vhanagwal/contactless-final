//
//  TableState.swift
//  Contactless
//
//  Created by Vardhan Agrawal on 9/1/17.
//  Copyright © 2017 Vardhan Agrawal. All rights reserved.
//

import UIKit

enum TableState {
  case Loading
  case Failed
  case Loaded([Contact])
  case Empty
}
