using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Serialization;
public class CalendarChange
{
    public string Description { get; set; }
    public DateTime Date { get; set; }
}
public class CalendarEvent
{
    public string Title { get; set; }
    public DateTime DateAndTime { get; set; }
    public string Description { get; set; }
}
public class Calendar
{
    private List<CalendarEvent> events = new List<CalendarEvent>();
    private List<CalendarChange> changes = new List<CalendarChange>();
    private DateTime currentDate;

    public Calendar(DateTime initialDate)
    {
        currentDate = initialDate;
    }
    public void AddEvent(CalendarEvent newEvent)
    {
        events.Add(newEvent);
        changes.Add(new CalendarChange { Description = $"+ Добавлено событие: {newEvent.Title}", Date = DateTime.Now });
    }
    public void RemoveEvent(CalendarEvent eventToRemove)
    {
        events.Remove(eventToRemove);
        changes.Add(new CalendarChange { Description = $"- Удалено событие: {eventToRemove.Title}", Date = DateTime.Now });
    }
    public void ChangeDate(DateTime newDate)
    {
        changes.Add(new CalendarChange { Description = $"_ Изменена дата с {currentDate.ToShortDateString()} на {newDate.ToShortDateString()}", Date = DateTime.Now });
        currentDate = newDate;
    }
    public void RemovePastEvents()
    {
        var removedEvents = events.Where(e => e.DateAndTime < currentDate).ToList();
        foreach (var e in removedEvents)
        {
            RemoveEvent(e);
        }
    }
    public void SaveToXml(string fileName)
    {
        XmlSerializer serializer = new XmlSerializer(typeof(List<CalendarChange>));
        using (FileStream fs = new FileStream(fileName, FileMode.Create))
        {
            serializer.Serialize(fs, changes);
        }
    }
    public void LoadFromXml(string fileName)
    {
        XmlSerializer serializer = new XmlSerializer(typeof(List<CalendarChange>));
        using (FileStream fs = new FileStream(fileName, FileMode.Open))
        {
            changes = (List<CalendarChange>)serializer.Deserialize(fs);
        }
    }
    public void ShowEventsOnCurrentDate()
    {
        Console.WriteLine($"События на {currentDate.ToShortDateString()}:");
        var dailyEvents = events.Where(e => e.DateAndTime.Date == currentDate.Date).ToList();
        for (int i = 0; i < dailyEvents.Count; i++)
        {
            Console.WriteLine($"{i + 1}. {dailyEvents[i].Title}: {dailyEvents[i].Description}");
        }
    }
    public void ShowChanges()
    {
        Console.WriteLine("Сохраненные изменения:");
        foreach (var change in changes)
        {
            Console.WriteLine($"- {change.Date.ToString("yyyy-MM-dd HH:mm:ss")}: {change.Description}");
        }
    }
    public void AddNoteToEvent()
    {
        Console.Write("Введите текст записи: ");
        string noteText = Console.ReadLine();
        Console.Write("На какую дату? (ГГГГ-ММ-ДД): ");
        DateTime noteDate;
        while (!DateTime.TryParse(Console.ReadLine(), out noteDate))
        {
            Console.WriteLine("Некорректный формат даты. Попробуйте еще раз.");
        }
        events.Add(new CalendarEvent { Title = "Заметка", DateAndTime = noteDate, Description = noteText });
        changes.Add(new CalendarChange { Description = $"+ Добавлена запись: {noteText} на дату {noteDate.ToShortDateString()}", Date = DateTime.Now });
    }
    public void RemoveNoteFromEvent()
    {
        Console.WriteLine($"Выберите запись для удаления на {currentDate.ToShortDateString()}:");
        var dailyEvents = events.Where(e => e.DateAndTime.Date == currentDate.Date).ToList();
        for (int i = 0; i < dailyEvents.Count; i++)
        {
            Console.WriteLine($"{i + 1}. {dailyEvents[i].Title}: {dailyEvents[i].Description}");
        }
        int noteIndex;
        while (!int.TryParse(Console.ReadLine(), out noteIndex) || noteIndex < 1 || noteIndex > dailyEvents.Count)
        {
            Console.WriteLine("Некорректный выбор. Попробуйте еще раз.");
        }
        var noteToRemove = dailyEvents[noteIndex - 1];
        events.Remove(noteToRemove);
        changes.Add(new CalendarChange { Description = $"- Удалена запись: {noteToRemove.Description} на дату {noteToRemove.DateAndTime.ToShortDateString()}", Date = DateTime.Now });
    }
}
class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Добро пожаловать в управление календарем!");

        Console.Write("Введите начальную дату в формате ГГГГ-ММ-ДД: ");
        DateTime initialDate;
        while (!DateTime.TryParse(Console.ReadLine(), out initialDate))
        {
            Console.WriteLine("Некорректный формат даты. Попробуйте еще раз.");
        }

        Calendar calendar = new Calendar(initialDate);
        bool running = true;

        while (running)
        {
            Console.WriteLine();
            Console.WriteLine("Выберите действие:");
            Console.WriteLine("1. Просмотр сведений и записей на календаре");
            Console.WriteLine("2. Изменение сегодняшней даты в календаре");
            Console.WriteLine("3. Добавить или убрать запись на календаре");
            Console.WriteLine("4. Просмотр изменений");
            Console.WriteLine("5. Выключить календарь");

            int choice;
            while (!int.TryParse(Console.ReadLine(), out choice) || choice < 1 || choice > 5)
            {
                Console.WriteLine("Некорректный выбор. Попробуйте еще раз.");
            }

            switch (choice)
            {
                case 1:
                    calendar.ShowEventsOnCurrentDate();
                    break;
                case 2:
                    Console.Write("Введите новую сегодняшнюю дату в формате ГГГГ-ММ-ДД: ");
                    DateTime newDate;
                    while (!DateTime.TryParse(Console.ReadLine(), out newDate))
                    {
                        Console.WriteLine("Некорректный формат даты. Попробуйте еще раз.");
                    }
                    calendar.ChangeDate(newDate);
                    calendar.RemovePastEvents();
                    break;
                case 3:
                    Console.WriteLine("Выберите действие:");
                    Console.WriteLine("1. Добавить запись");
                    Console.WriteLine("2. Убрать запись");
                    int actionChoice;
                    while (!int.TryParse(Console.ReadLine(), out actionChoice) || actionChoice < 1 || actionChoice > 2)
                    {
                        Console.WriteLine("Некорректный выбор. Попробуйте еще раз.");
                    }
                    if (actionChoice == 1)
                    {
                        calendar.AddNoteToEvent();
                    }
                    else
                    {
                        calendar.RemoveNoteFromEvent();
                    }
                    break;
                case 4:
                    calendar.ShowChanges();
                    break;
                case 5:
                    running = false;
                    break;
            }
        }

        Console.WriteLine("Календарь выключен. Сохранение данных в XML...");
        calendar.SaveToXml("calendar_changes.xml");
        Console.WriteLine("Данные сохранены.");
    }
}
