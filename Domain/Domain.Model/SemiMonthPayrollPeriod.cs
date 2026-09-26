using System;
using System.Globalization;

namespace PayrollEngine.Domain.Model;

/// <summary>Payroll semi month payroll period</summary>
public class SemiMonthPayrollPeriod : IPayrollPeriod
{
    private DatePeriod Period { get; }

    /// <summary>
    /// The culture
    /// </summary>
    private CultureInfo Culture { get; }

    /// <summary>
    /// The date calendar
    /// </summary>
    private Calendar Calendar { get; }

    /// <summary>Initializes a new instance of the <see cref="SemiMonthPayrollPeriod"/> class</summary>
    /// <param name="culture">The culture</param>
    /// <param name="calendar">The calendar</param>
    /// <param name="moment">The moment within the semi mont period</param>
    public SemiMonthPayrollPeriod(CultureInfo culture, Calendar calendar, DateTime moment)
    {
        // arguments
        Culture = culture ?? throw new ArgumentNullException(nameof(culture));
        Calendar = calendar ?? throw new ArgumentNullException(nameof(calendar));

        // semi month days
        var daysInMonth = DateTime.DaysInMonth(moment.Year, moment.Month);
        var secondHalfStartDay = Date.DaysInSemiMonth + 1;

        // first half period
        if (moment.Day < secondHalfStartDay)
        {
            var start = new DateTime(moment.Year, moment.Month, 1, 0, 0, 0, 0, culture.Calendar, DateTimeKind.Utc);
            var end = new DateTime(moment.Year, moment.Month, secondHalfStartDay, 0, 0, 0, 0, culture.Calendar, DateTimeKind.Utc)
                .AddDays(-1).LastMomentOfDay();
            Period = new(start, end);
        }
        else
        {
            // second half period
            var start = new DateTime(moment.Year, moment.Month, secondHalfStartDay, 0, 0, 0, 0, culture.Calendar, DateTimeKind.Utc);
            var end = new DateTime(moment.Year, moment.Month, daysInMonth, 0, 0, 0, 0, culture.Calendar, DateTimeKind.Utc)
                .LastMomentOfDay();
            Period = new(start, end);
        }
    }

    #region IPayrollPeriod

    /// <inheritdoc />
    public DateTime Start => Period.Start;

    /// <inheritdoc />
    public DateTime End => Period.End;

    /// <inheritdoc />
    public string Name =>
        $"{Period.Start.ToCompactString()} - {Period.End.ToCompactString()}";

    /// <inheritdoc />
    public IPayrollPeriod GetPayrollPeriod(DateTime moment, int offset = 0)
    {
        if (offset == 0) return new SemiMonthPayrollPeriod(Culture, Calendar, moment);
        // AddMonths(offset) would overshoot by a full month (skipping the opposite half).
        // Step period by period using Start/End boundaries instead.
        IPayrollPeriod result = this;
        var step = Math.Sign(offset);
        for (var i = 0; i < Math.Abs(offset); i++)
            result = step > 0
                ? new SemiMonthPayrollPeriod(Culture, Calendar, result.End.Date.AddDays(1))
                : new SemiMonthPayrollPeriod(Culture, Calendar, result.Start.AddDays(-1));
        return result;
    }

    #endregion

    /// <inheritdoc />
    public override string ToString() => Name;
}