class Job::JobEventsQuery
  def initialize(person)
    @person = person
  end

  def for_job_description(job)
    if job.is_created_by?(@person)
      sql = <<-SQL
        SELECT job_events.*
        FROM job_events
          INNER JOIN job_applications ON
            job_events.job_eventable_type = 'JobApplication' AND
            job_events.job_eventable_id = job_applications.id
        WHERE job_events.job_id = %{job}
        UNION
        (
          SELECT job_events.*
          FROM job_events
            INNER JOIN messages ON
              job_events.job_eventable_type = 'Message' AND
              job_events.job_eventable_id = messages.id
          WHERE
            messages.id IN (
                            SELECT MIN(id)
                            FROM messages
                            WHERE recepient_id = %{person} AND
                              status = 'inquiry'
                            GROUP BY (sender_id)
                            ) AND
            job_events.job_id = %{job}
        )
        UNION
        (
          SELECT job_events.*
          FROM job_events
            INNER JOIN price_negotiations ON
              job_events.job_eventable_type = 'PriceNegotiation' AND
              job_events.job_eventable_id = price_negotiations.id
          WHERE
            job_events.job_id = %{job}
        )
        ORDER BY created_at DESC
      SQL
    else
      sql = <<-SQL
        SELECT job_events.*
        FROM job_events
          INNER JOIN job_applications ON
            job_events.job_eventable_type = 'JobApplication' AND
            job_events.job_eventable_id = job_applications.id
        WHERE job_applications.person_id = %{person} AND
          job_events.job_id = %{job}
        UNION
        (
          SELECT job_events.*
          FROM job_events
            INNER JOIN messages ON
              job_events.job_eventable_type = 'Message' AND
              job_events.job_eventable_id = messages.id
          WHERE messages.sender_id = %{person} AND
            job_events.job_id = %{job} AND
            messages.status = 'inquiry'
          LIMIT 1
        )
        UNION
        (
          SELECT job_events.*
          FROM job_events
            INNER JOIN price_negotiations ON
              job_events.job_eventable_type = 'PriceNegotiation' AND
              job_events.job_eventable_id = price_negotiations.id
          WHERE price_negotiations.person_id = %{person} AND
            job_events.job_id = %{job}
        )
        ORDER BY created_at DESC
      SQL
    end
    JobEvent.find_by_sql( sql % { person: @person.id, job: job.id })
  end

  def for_inbox
    sql = <<-SQL
      SELECT
        job_events.id,
        job_events.job_id,
        job_events.job_eventable_type,
        job_events.read,
        job_applications.id AS job_eventable_id,
        job_applications.person_id AS person_id,
        job_events.created_at AS created_at,
        job_events.initial_event
      FROM job_applications
        INNER JOIN job_events ON
          job_events.job_eventable_type = 'JobApplication' AND
          job_events.job_eventable_id = job_applications.id
        INNER JOIN jobs ON
          job_events.job_id = jobs.id
      WHERE
        job_applications.person_id <> jobs.person_id AND
        (
          job_applications.person_id = %{person} OR
          jobs.person_id = %{person}
        )
      UNION
      SELECT
        job_events.id,
        job_events.job_id,
        job_events.job_eventable_type,
        job_events.read,
        price_negotiations.id AS job_eventable_id,
        price_negotiations.person_id AS person_id,
        job_events.created_at AS created_at,
        job_events.initial_event
      FROM price_negotiations
        INNER JOIN job_events ON
          job_events.job_eventable_type = 'PriceNegotiation' AND
          job_events.job_eventable_id = price_negotiations.id
        INNER JOIN jobs ON
          job_events.job_id = jobs.id
      WHERE
        price_negotiations.person_id <> jobs.person_id AND
        (
          price_negotiations.person_id = %{person} OR
          jobs.person_id = %{person}
        )
      UNION
      SELECT
        job_events.id,
        job_events.job_id,
        job_events.job_eventable_type,
        job_events.read,
        messages.id AS job_eventable_id,
        messages.sender_id AS person_id,
        job_events.created_at AS created_at,
        job_events.initial_event
      FROM messages
        INNER JOIN job_events ON
          job_events.job_eventable_type = 'Message' AND
          job_events.job_eventable_id = messages.id
        INNER JOIN jobs ON job_events.job_id = jobs.id
      WHERE
        (
          (messages.sender_id <> jobs.person_id AND messages.sender_id = %{person}) OR
          (messages.sender_id <> jobs.person_id AND jobs.person_id = %{person})
        )
        AND
        (messages.status <> 'draft')
      UNION
      SELECT
        job_events.id,
        job_events.job_id,
        job_events.job_eventable_type,
        job_events.read,
        messages.id AS job_eventable_id,
        messages.recepient_id AS person_id,
        job_events.created_at AS created_at,
        job_events.initial_event
      FROM messages
      INNER JOIN job_events ON
        job_events.job_eventable_type = 'Message' AND
        job_events.job_eventable_id = messages.id
      INNER JOIN jobs ON
        job_events.job_id = jobs.id
      WHERE
        (
          (messages.recepient_id <> jobs.person_id AND messages.recepient_id = %{person}) OR
          (messages.recepient_id <> jobs.person_id AND jobs.person_id = %{person})
        )
        AND (messages.status <> 'draft')
      UNION
      SELECT
        job_events.id,
        job_events.job_id,
        job_events.job_eventable_type,
        job_events.read,
        invites.id AS job_eventable_id,
        invites.person_id AS person_id,
        job_events.created_at AS created_at,
        job_events.initial_event
      FROM invites
      INNER JOIN job_events ON
        job_events.job_eventable_type = 'Invite' AND
        job_events.job_eventable_id = invites.id
      INNER JOIN jobs ON
        job_events.job_id = jobs.id
      WHERE
        invites.person_id <> jobs.person_id AND
        (
          invites.person_id = %{person} OR
          jobs.person_id = %{person}
        )
      ORDER BY created_at DESC
      SQL
    JobEvent.find_by_sql( sql % { person: @person.id })
  end
end
