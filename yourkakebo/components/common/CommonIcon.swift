//
//  CommonI.swift
//  yourkakebo
//
//  Created by hiroki hosokawa on 2026/10/15.
//

import SwiftUI

struct CloseIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "xmark")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(.primary)
    }
}

struct CheckIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(color)
    }
}

struct CheckSmallIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 16, weight: .light))
            .foregroundColor(color)
    }
}

struct PlusIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(color)
    }
}

struct PlusSmallIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 18, weight: .light))
            .foregroundColor(color)
    }
}

struct PrevPageIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image("chevron.left")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(color)
    }
}

struct NextPageIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 18, weight: .light))
            .foregroundColor(color)
    }
}

struct PeriodBackIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image("chevron.left")
            .font(.system(size: 18))
            .foregroundColor(color)
    }
}

struct PeriodNextIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image("chevron.right")
            .font(.system(size: 18))
            .foregroundColor(color)
    }
}

struct EditIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image("pencil")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(color)
    }
}

struct DeleteIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image("trash")
            .font(.system(size: 22, weight: .light))
            .foregroundColor(color)
    }
}

struct SettingIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "gearshape")
           .font(.system(size: 19))
    }
}

struct ListToggleIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "list.bullet")
           .font(.system(size: 19))
    }
}

struct CalendarToggleIcon: View {
    var color: Color = .primary
    
    var body: some View {
        Image(systemName: "calendar")
           .font(.system(size: 19))
    }
}

