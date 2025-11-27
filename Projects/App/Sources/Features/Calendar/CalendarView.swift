import SwiftUI
import ComposableArchitecture
import DSKit

struct CalendarView: View {
    @Bindable var store: StoreOf<CalendarFeature>
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 12) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                
                Group {
                    if store.viewMode == .month {
                        MonthView(
                            currentDate: store.currentDate,
                            selectedDate: store.selectedDate,
                            events: store.events,
                            onSelectDate: { store.send(.selectDate($0)) }
                        )
                    } else {
                        WeekView(
                            currentDate: store.currentDate,
                            events: store.events,
                            selectedDate: store.selectedDate,
                            onSelectDate: { store.send(.selectDate($0)) }
                        )
                    }
                }
                .transition(.opacity.combined(with: .scale))
                .padding(.horizontal, 16)
                .padding(.top, 4)
                
                eventList
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
            }
            
            addButton
                .padding(.trailing, 20)
                .padding(.bottom, 24)
        }
        .onAppear {
            store.send(.fetchEvents)
        }
    }
    
    private var header: some View {
        VStack(spacing: 14) {
            // Top bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.currentDate.formatted(.dateTime.month(.wide)))
                        .font(AngelTypography.title1(.bold))
                    Text(store.currentDate.formatted(.dateTime.year()))
                        .font(AngelTypography.caption(.medium))
                        .foregroundStyle(Color.angelTextSecondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    capsuleButton(title: "Today", systemImage: "clock", action: { store.send(.goToday) })
                    roundIcon("magnifyingglass")
                    roundIcon("calendar")
                    roundIcon("gearshape")
                }
            }
            
            // View mode and month navigation
            HStack(spacing: 10) {
                roundIcon("chevron.left", action: { store.send(.previousMonth) })
                roundIcon("chevron.right", action: { store.send(.nextMonth) })
                
                Spacer()
                
                Picker("", selection: .constant(store.viewMode)) {
                    Text("Month").tag(CalendarFeature.State.ViewMode.month)
                    Text("Week").tag(CalendarFeature.State.ViewMode.week)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                .colorMultiply(.white)
            }
        }
    }
    
    private var eventsForDisplay: [EventDTO] {
        let calendar = Calendar.current
        return store.events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: store.selectedDate)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private var eventList: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(AngelTypography.caption(.medium))
                    .foregroundStyle(Color.angelTextSecondary)
                Text(store.selectedDate.formatted(.dateTime.year().month().day()))
                    .font(AngelTypography.headline(.bold))
            }
            .padding(.horizontal, 8)
            
            if eventsForDisplay.isEmpty {
                HStack {
                    Text("이 날의 일정이 없어요.")
                        .font(AngelTypography.callout())
                        .foregroundStyle(Color.angelTextSecondary)
                    Spacer()
                }
                .padding()
                .background(AngelColors.card)
                .cornerRadius(14)
            } else {
                VStack(spacing: 10) {
                    ForEach(eventsForDisplay) { event in
                        EventRow(event: event)
                            .onTapGesture {
                                store.send(.eventTapped(event))
                            }
                    }
                }
            }
            
            addNewEventRow
        }
        .padding(.bottom, 8)
    }
    
    private var addButton: some View {
        Button {
            store.send(.addEventButtonTapped)
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(Color.white)
                .frame(width: 56, height: 56)
                .background(AngelColors.primary)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.25), radius: 10, y: 6)
        }
    }
    
    private var addNewEventRow: some View {
        Button {
            store.send(.addEventButtonTapped)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .foregroundStyle(Color.angelTextPrimary)
                Text("새로운 이벤트")
                    .font(AngelTypography.body())
                    .foregroundStyle(Color.angelTextPrimary)
                Spacer()
                Image(systemName: "text.alignleft")
                    .foregroundStyle(Color.angelTextSecondary)
            }
            .padding()
            .background(AngelColors.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AngelColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func capsuleButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(AngelTypography.caption(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AngelColors.card)
            .foregroundStyle(Color.angelTextPrimary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(AngelColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func roundIcon(_ systemName: String, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(AngelColors.card)
                .foregroundStyle(Color.angelTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AngelColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct EventRow: View {
    let event: EventDTO
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.startDate, style: event.isAllDay ? .date : .time)
                    .font(AngelTypography.callout(.semibold))
                    .foregroundStyle(Color.angelTextSecondary)
                Text(event.title)
                    .font(AngelTypography.body(.semibold))
                    .foregroundStyle(Color.angelTextPrimary)
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(AngelTypography.caption())
                        .foregroundStyle(Color.angelTextSecondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AngelColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AngelColors.border, lineWidth: 1)
                .overlay(
                    Rectangle()
                        .fill(color(for: event))
                        .frame(width: 4)
                        .cornerRadius(2)
                        .padding(.vertical, 10),
                    alignment: .leading
                )
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
    }
    
    private func color(for event: EventDTO) -> Color {
        let palette: [Color] = [
            AngelColors.primary,
            AngelColors.accent,
            Color.angelAmber,
            Color.angelRed,
            Color.angelPurple,
        ]
        let index = abs(event.title.hashValue) % palette.count
        return palette[index]
    }
}

struct MonthView: View {
    let currentDate: Date
    let selectedDate: Date
    let events: [EventDTO]
    let onSelectDate: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        
        return calendar.generateDates(
            inside: dateInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Weekday Headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(AngelTypography.caption(.medium))
                        .foregroundStyle(Color.angelTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { date in
                    DayCell(
                        date: date,
                        isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasEvents: eventsForDay(date).count > 0,
                        highlightDots: Array(eventsForDay(date).prefix(3)).map { $0.title }
                    )
                    .onTapGesture {
                        onSelectDate(date)
                    }
                }
            }
        }
    }
    
    private func eventsForDay(_ date: Date) -> [EventDTO] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
}


struct DayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let hasEvents: Bool
    let highlightDots: [String]
    
    private let calendar = Calendar.current
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(calendar.component(.day, from: date))")
                .font(AngelTypography.body(.medium))
                .foregroundStyle(foregroundColor)
                .frame(width: 34, height: 34)
                .background(backgroundShape)
            
            HStack(spacing: 2) {
                if hasEvents && isCurrentMonth {
                    ForEach(highlightDots.indices, id: \.self) { index in
                        Circle()
                            .fill(dotColor(for: index))
                            .frame(width: 4, height: 4)
                    }
                } else {
                    Spacer(minLength: 4)
                }
            }
        }
        .frame(height: 50)
    }
    
    private var backgroundShape: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AngelColors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AngelColors.border, lineWidth: 1.2)
                    )
            } else if isToday {
                Circle().stroke(AngelColors.accent, lineWidth: 2)
            } else {
                Color.clear
            }
        }
    }
    
    private var foregroundColor: Color {
        guard isCurrentMonth else { return Color.angelTextTertiary }
        if isSelected { return Color.angelTextPrimary }
        if isToday { return AngelColors.accent }
        return Color.angelTextSecondary
    }
    
    private func dotColor(for index: Int) -> Color {
        let palette: [Color] = [
            Color(red: 0.29, green: 0.51, blue: 0.94),
            Color(red: 0.95, green: 0.58, blue: 0.2),
            Color(red: 0.2, green: 0.7, blue: 0.47),
            Color(red: 0.86, green: 0.33, blue: 0.33),
            Color(red: 0.57, green: 0.46, blue: 0.94),
        ]
        return palette[index % palette.count]
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}

struct WeekView: View {
    let currentDate: Date
    let events: [EventDTO]
    let selectedDate: Date
    let onSelectDate: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var days: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: currentDate)
        else { return [] }
        
        let dateInterval = DateInterval(start: weekInterval.start, end: weekInterval.end - 1)
        
        return calendar.generateDates(
            inside: dateInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Weekday Headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(AngelTypography.caption(.medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(days, id: \.self) { date in
                    DayCell(
                        date: date,
                        isCurrentMonth: true,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasEvents: hasEvents(on: date),
                        highlightDots: Array(eventsForDay(date).prefix(3)).map { $0.title }
                    )
                    .onTapGesture { onSelectDate(date) }
                }
            }
            
            Spacer()
        }
    }
    
    private func hasEvents(on date: Date) -> Bool {
        events.contains { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
    
    private func eventsForDay(_ date: Date) -> [EventDTO] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
}
