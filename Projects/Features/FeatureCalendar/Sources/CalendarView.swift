import SwiftUI
import ComposableArchitecture
import DSKit
import Core
import FeatureEventEdit

public struct CalendarView: View {
    @Bindable public var store: StoreOf<CalendarFeature>
    
    public init(store: StoreOf<CalendarFeature>) {
        self.store = store
    }
    
    var today: Date { Date() }
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    public var body: some View {
        VStack {
            HStack {
                Text(formattedMonth(store.selectedDate))
                    .font(.title2)
                    .bold()
                Spacer()
                Button("새로고침") { store.send(.pullToRefresh) }
                Button("추가") { store.send(.setEventEditPresented(true)) }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<28, id: \.self) { idx in
                    let date = Calendar.current.date(byAdding: .day, value: idx, to: startOfWeek(for: store.selectedDate)) ?? store.selectedDate
                    Text(shortDay(date))
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(CalendarCellStyle.background(isToday: isToday(date)))
                        .foregroundStyle(CalendarCellStyle.textColor(isToday: isToday(date)))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .onTapGesture { store.send(.setDate(date)) }
                }
            }
            .padding(.horizontal)
            
            DayListView(store: store.scope(state: \.
 dayList, action: \.dayList))
        }
        .sheet(isPresented: $store.showingEventEdit) {
            EventEditView(store: store.scope(state: \.
 eventEditState, action: \.eventEdit))
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: today)
    }
    private func shortDay(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }
    private func formattedMonth(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM"
        return df.string(from: date)
    }
    private func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }
}
