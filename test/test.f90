program test

    use, intrinsic :: ISO_Fortran_env, only: &
        stdout => OUTPUT_UNIT, &
        compiler_version, &
        compiler_options

    use cpu_timer_library, only: &
        CpuTimer, &
        wp, & ! working precision
        ip ! integer precision

    ! Explicit typing only
    implicit none
    
    call test_all()
    
contains

    subroutine test_all()
        !-----------------------------------------------------------------------
        ! Local variables
        !-----------------------------------------------------------------------
        class (CpuTimer), allocatable :: timer
        !-----------------------------------------------------------------------

        !
        !==> Allocate memory
        !
        allocate( CpuTimer :: timer )

        write( stdout, '(/a/)' ) '  Demonstrate the usage of type (CpuTimer).'

        ! print time stamp
        call timer%print_time_stamp()

        !
        !==> Time various calculations
        !
        call time_random_number_routine()
        call time_vectorized_exp_routine()
        call time_unvectorized_exp_routine()
        call time_2d_nearest_neighbor_problem()
        call time_matrix_multiplication_problem()

        !
        !==> Terminate
        !
        write( stdout, '(/a/)' ) ' type (CpuTimer) tests.'
        write( stdout, '(a/)' ) ' Normal end of execution.'

        !
        !==> Print time stamp
        !
        call timer%print_time_stamp()

        !
        !==> Print compiler info
        !
        call timer%print_compiler_info()

        !
        !==> Release memory
        !
        deallocate( timer )

    end subroutine test_all

    subroutine time_random_number_routine()
        !
        !  Purpose:
        !
        !  Times the intrinsic random_number routine.
        !
        !
        !  Licensing:
        !
        !    This code is distributed under the GNU LGPL license.
        !
        !-----------------------------------------------------------------------
        !
        ! Record of revisions:
        !
        !   Date             Programmer             Description of change
        !   ---------      ----------------       --------------------------
        !   05/20/09       John Burkardt          Original procedural code
        !   12/20/15       Jon Lo Kim Lin         Object-oriented implementation
        !
        !-----------------------------------------------------------------------
        ! Local variables
        !-----------------------------------------------------------------------
        type (CpuTimer)        :: timer
        integer(ip)            :: n_log, rep   !! Counters
        integer(ip), parameter :: N_LOG_MIN = 0
        integer(ip), parameter :: N_LOG_MAX = 20
        integer(ip), parameter :: N_MIN = 2**N_LOG_MIN
        integer(ip), parameter :: N_MAX = 2**N_LOG_MAX
        integer(ip), parameter :: REP_NUM = 5
        real(wp)               :: delta(N_LOG_MIN:N_LOG_MAX, REP_NUM + 3)
        real(wp)               :: x(N_MAX)
        !-----------------------------------------------------------------------

        !
        !==> Print program description
        !
        write( stdout, '(/a/)' )     '*********************************************'
        write( stdout, '(a/)' )     ' time_random_number_routine'
        write( stdout, '(a/)' )     ' times the intrinsic random_number routine:'
        write( stdout, '(a/)' )     '    call random_number( x(1:n) )'
        write( stdout, '(a, i11)' ) '  Data vectors will be of minimum size    ', N_MIN
        write( stdout, '(a, i11)' ) '  Data vectors will be of maximum size    ', N_MAX
        write( stdout, '(a, i11)' ) '  Number of repetitions of the operation: ', REP_NUM

        !
        !==> Perform calculation
        !
        do n_log = N_LOG_MIN, N_LOG_MAX
            do rep = 1, REP_NUM
                associate( n => 2**(n_log) )

                    ! start timer
                    call timer%start()

                    call random_number(harvest=x)

                    ! stop timer
                    call timer%stop()

                    ! Set CPU time
                    delta(n_log, rep) = timer%get_elapsed_time()

                end associate
            end do
            delta(n_log, REP_NUM + 1) = minval( delta(n_log,1:REP_NUM) )
            delta(n_log, REP_NUM + 2) = sum( delta(n_log,1:REP_NUM) ) /  REP_NUM
            delta(n_log, REP_NUM + 3) = maxval( delta(n_log,1:REP_NUM) )
        end do


        !
        !==> Print results
        !
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  Timing results:'
        write( stdout, '(a)' ) ''
        write( stdout, '(9A)' ) &
            '       Size    ',&
            'Rep #1         ', &
            'Rep #2         ',&
            'Rep #3         ',&
            'Rep #4         ',&
            'Rep #5         ',&
            'MINVAL         ',&
            'SUM            ',&
            'MAXVAL         '
        write( stdout, '(a)' ) ''

        do n_log = N_LOG_MIN, N_LOG_MAX
            associate( n => 2**(n_log) )
                write( stdout, '(I11, 8(1PE15.5))' ) &
                    n, delta(n_log,:)
            end associate
        end do

    end subroutine time_random_number_routine

    subroutine time_vectorized_exp_routine()
        !
        !  Purpose:
        !
        !  Times the vectorized EXP routine.
        !
        !
        !  Licensing:
        !
        !    This code is distributed under the GNU LGPL license.
        !
        !-----------------------------------------------------------------------
        !
        ! Record of revisions:
        !
        !   Date             Programmer             Description of change
        !   ---------      ----------------       --------------------------
        !   02/06/07       John Burkardt          Original procedural code
        !   12/20/15       Jon Lo Kim Lin         Object-oriented implementation
        !
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type (CpuTimer)         :: timer
        integer(ip)             :: func, i_rep, n_log !! Counters
        integer(ip), parameter  :: N_LOG_MIN = 12
        integer(ip), parameter  :: N_LOG_MAX = 22
        integer(ip), parameter  :: N_MIN = 2**N_LOG_MIN
        integer(ip), parameter  :: N_MAX = 2**N_LOG_MAX
        integer(ip), parameter  :: N_REP = 5
        real(wp),    parameter  :: PI = acos(-1.0_wp)
        real(wp)                :: delta(N_LOG_MAX, N_REP)
        real(wp)                :: x(N_MAX)
        real(wp)                :: y(N_MAX)
        !----------------------------------------------------------------------

        !
        !==> Print program description
        !
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '*********************************************'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  time_vectorized_exp_routine:'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '    y(1:n) = x(1:n)  '
        write( stdout, '(a)' ) '    y(1:n) = PI * x(1:n)  '
        write( stdout, '(a)' ) '    y(1:n) = sqrt( x(1:n) )'
        write( stdout, '(a)' ) '    y(1:n) = exp( x(1:n) )'
        write( stdout, '(a)' ) ''
        write( stdout, '(a, i11)' ) '  Data vectors will be of minimum size    ', N_MIN
        write( stdout, '(a, i11)' ) '  Data vectors will be of maximum size    ', N_MAX
        write( stdout, '(a, i11)' ) '  Number of repetitions of the operation: ', N_REP

        !
        !==> Perform optimized calculation
        !
        do func = 1, 4
            do i_rep = 1, N_REP
                do n_log = N_LOG_MIN, N_LOG_MAX
                    associate( n => 2**(n_log) )

                        ! Generate some random data
                        call random_number(harvest=x)

                        ! start timer
                        call timer%start()

                        ! Evaluate functions
                        select case(func)
                            case(1)! First function
                                y = x
                            case(2)! Second function
                                y = PI * x
                            case(3)! Third function
                                y = sqrt( x )
                            case(4)! Fourth function
                                y = exp( x )
                            case default
                                exit
                        end select
                    end associate

                    ! stop the timer
                    call timer%stop()

                    ! Set CPU time
                    delta(n_log, i_rep) = timer%get_elapsed_time()
                end do
            end do
            !
            !==> Print optimized results
            !
            write( stdout, '(a)' ) ''
            write( stdout, '(a)' ) '  Timing results:'
            write( stdout, '(a)' ) ''
            write( stdout, '(6A)' ) &
                '       Size    ',&
                'Rep #1         ', &
                'Rep #2         ',&
                'Rep #3         ',&
                'Rep #4         ',&
                'Rep #5         '
            write( stdout, '(a)' ) ''

            do n_log = N_LOG_MIN, N_LOG_MAX
                associate( n => 2**(n_log) )
                    write( stdout, '(I11, 5(1PE15.5))' ) n, delta(n_log,:)
                end associate
            end do
        end do

    end subroutine time_vectorized_exp_routine

    subroutine time_unvectorized_exp_routine()
        !
        !  Purpose:
        !
        !  Times the unvectorized EXP routine.
        !
        !
        !  Licensing:
        !
        !    This code is distributed under the GNU LGPL license.
        !
        !-----------------------------------------------------------------------
        !
        ! Record of revisions:
        !
        !   Date             Programmer             Description of change
        !   ---------      ----------------       --------------------------
        !   02/06/07       John Burkardt          Original procedural code
        !   12/20/15       Jon Lo Kim Lin         Object-oriented implementation
        !
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type (CpuTimer)         :: timer
        integer(ip)             :: func, i, i_rep, n_log !! Counters
        integer(ip), parameter  :: N_LOG_MIN = 12
        integer(ip), parameter  :: N_LOG_MAX = 22
        integer(ip), parameter  :: N_MIN = 2**N_LOG_MIN
        integer(ip), parameter  :: N_MAX = 2**N_LOG_MAX
        integer(ip), parameter  :: N_REP = 5
        real(wp),    parameter  :: PI = acos(-1.0_wp)
        real(wp)                :: delta(N_LOG_MAX, N_REP)
        real(wp)                :: x(N_MAX)
        real(wp)                :: y(N_MAX)
        !----------------------------------------------------------------------

        !
        !==> Print program description
        !
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '*********************************************'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) ' time_unvectorized_exp_routine'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '    do i = 1, n'
        write( stdout, '(a)' ) '      y(i) = x(i)  '
        write( stdout, '(a)' ) '      y(i) = PI * x(i)  '
        write( stdout, '(a)' ) '      y(i) = sqrt(x(i))'
        write( stdout, '(a)' ) '      y(i) = exp(x(i))'
        write( stdout, '(a)' ) '    end do'
        write( stdout, '(a)' ) ''
        write( stdout, '(a, i11)' ) '  Data vectors will be of minimum size    ',    N_MIN
        write( stdout, '(a, i11)' ) '  Data vectors will be of maximum size    ',    N_MAX
        write( stdout, '(a, i11)' ) '  Number of repetitions of the operation: ', N_REP

        !
        !==> Perform naive calculation
        !
        loop_over_functions: do func = 1, 4
            do i_rep = 1, N_REP
                do n_log = N_LOG_MIN, N_LOG_MAX
                    associate( n => 2**(n_log))

                        ! Generate some random data
                        call random_number(harvest=x(1:n))

                        ! start timer
                        call timer%start()

                        !
                        !==> Evaluate functions
                        !
                        if (func == 1) then
                            ! First function
                            do i = 1, n
                                y(i) = x(i)
                            end do
                        else if (func == 2) then
                            ! Second function
                            do i = 1, n
                                y(i) = PI * x(i)
                            end do
                        else if (func == 3) then
                            ! Third function
                            do i = 1, n
                                y(i) = sqrt(x(i))
                            end do
                        else if (func == 4) then
                            ! Fourth function
                            do i = 1, n
                                y(i) = exp(x(i))
                            end do
                        else
                            exit
                        end if
                    end associate

                    ! stop timer
                    call timer%stop()

                    ! Set CPU time
                    delta(n_log, i_rep) = timer%get_elapsed_time()
                end do
            end do

            !
            !==> Print naive results
            !
            write( stdout, '(a)' ) ''
            write( stdout, '(a)' ) '*********************************************'
            write( stdout, '(a)' ) ''
            write( stdout, '(a)' ) '  Timing results:'
            write( stdout, '(a)' ) ''
            write( stdout, '(6A)' ) &
                '       Size    ',&
                'Rep #1         ', &
                'Rep #2         ',&
                'Rep #3         ',&
                'Rep #4         ',&
                'Rep #5         '
            write( stdout, '(a)' ) ''

            do n_log = N_LOG_MIN, N_LOG_MAX
                associate( n => 2**(n_log) )
                    write( stdout, '(I11, 5(1PE15.5))' ) n, delta(n_log,:)
                end associate
            end do
        end do loop_over_functions

    end subroutine time_unvectorized_exp_routine

    subroutine time_2d_nearest_neighbor_problem()
        !
        !  Purpose:
        !
        !  Times the 2D nearest neighbor problem.
        !
        !
        !  Licensing:
        !
        !    This code is distributed under the GNU LGPL license.
        !
        !-----------------------------------------------------------------------
        !
        ! Record of revisions:
        !
        !   Date             Programmer             Description of change
        !   ---------      ----------------       --------------------------
        !   02/06/07       John Burkardt          Original procedural code
        !   12/20/15       Jon Lo Kim Lin         Object-oriented implementation
        !
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type (CpuTimer)        :: timer
        integer(ip)            :: i, i_rep, n_log !! Counters
        integer(ip)            :: i_min
        integer(ip), parameter :: N_LOG_MIN = 10
        integer(ip), parameter :: N_LOG_MAX = 20
        integer(ip), parameter :: N_MIN = 2**N_LOG_MIN
        integer(ip), parameter :: N_MAX = 2**N_LOG_MAX
        integer(ip), parameter :: N_REP = 5
        real(wp)               :: delta(N_LOG_MAX, N_REP)
        real(wp)               :: x(2, N_MAX)
        real(wp)               :: y(2)
        real(wp)               :: dist_i, dist_min
        !----------------------------------------------------------------------

        !
        !==> Print program description
        !
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '*********************************************'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  time_2d_nearest_neighbor_problem'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  Given x(2,n) and y(2),'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '    find x(2,*) closest to y(2).'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '    do i = 1, n'
        write( stdout, '(a)' ) '      if distance( x(2,i), y ) < minimum so far'
        write( stdout, '(a)' ) '        x_min = x(2,i)'
        write( stdout, '(a)' ) '    end do'
        write( stdout, '(a)' ) ''
        write( stdout, '(a, i11)' ) '  Data vectors will be of minimum size    ', N_MIN
        write( stdout, '(a, i11)' ) '  Data vectors will be of maximum size    ', N_MAX
        write( stdout, '(a, i11)' ) '  Number of repetitions of the operation: ', N_REP

        !
        !==> Perform calculation
        !

        ! Generate some random data
        call random_number(harvest=x)
        call random_number(harvest=y)

        ! Solve nearest neighbor problem
        do i_rep = 1, N_REP
            do n_log = N_LOG_MIN, N_LOG_MAX
                associate( n => 2**(n_log) )

                    ! start timer
                    call timer%start()

                    dist_min = huge(dist_min)
                    i_min = 0

                    do i = 1, n
                        dist_i = sum(( x(:,i) - y )**2 )
                        if( dist_i < dist_min ) then
                            dist_min = dist_i
                            i_min = i
                        end if
                    end do

                    ! stop timer
                    call timer%stop()

                    ! Set CPU time
                    delta(n_log, i_rep) = timer%get_elapsed_time()

                end associate
            end do
        end do

        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  Timing results:'
        write( stdout, '(a)' ) ''
        write( stdout, '(6A)' ) &
            '       Size    ',&
            'Rep #1         ', &
            'Rep #2         ',&
            'Rep #3         ',&
            'Rep #4         ',&
            'Rep #5         '
        write( stdout, '(a)' ) ''

        do n_log = N_LOG_MIN, N_LOG_MAX
            associate( n => 2**(n_log) )
                write( stdout, '(I11,5(1PE15.5))' ) n, delta(n_log,:)
            end associate
        end do

    end subroutine time_2d_nearest_neighbor_problem

    subroutine time_matrix_multiplication_problem()
        !
        !  Purpose:
        !
        !  Times the matrix multiplication problem.
        !
        !
        !  Licensing:
        !
        !    This code is distributed under the GNU LGPL license.
        !
        !-----------------------------------------------------------------------
        !
        ! Record of revisions:
        !
        !   Date             Programmer             Description of change
        !   ---------      ----------------       --------------------------
        !   03/05/08       John Burkardt          Original procedural code
        !   12/20/15       Jon Lo Kim Lin         Object-oriented implementation
        !
        !----------------------------------------------------------------------
        ! Local variables
        !----------------------------------------------------------------------
        type (CpuTimer)           :: timer
        integer(ip)               :: i, j, k !! Counters
        integer(ip)               :: l_log, rep !! Counters
        integer(ip), parameter    :: L_LOG_MIN = 1
        integer(ip), parameter    :: L_LOG_MAX = 5
        integer(ip), parameter    :: L_MIN = 4**L_LOG_MIN
        integer(ip), parameter    :: L_MAX = 4**L_LOG_MAX
        integer(ip), parameter    :: REP_NUM = 5
        real(wp),    allocatable  :: a(:,:)
        real(wp),    allocatable  :: b(:,:)
        real(wp),    allocatable  :: c(:,:)
        real(wp)                  :: delta(L_LOG_MIN:L_LOG_MAX, 1:REP_NUM )
        !----------------------------------------------------------------------

        !
        !==> Print program description
        !
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '*********************************************'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  time_matrix_multiplication_problem'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  Compute C = A * B'
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  where'
        write( stdout, '(a)' ) '    A is an L by M matrix,'
        write( stdout, '(a)' ) '    B is an M by N matrix,'
        write( stdout, '(a)' ) '  and so'
        write( stdout, '(a)' ) '    C is an L by N matrix.'
        write( stdout, '(a)' ) ''
        write( stdout, '(a, i11)' ) '  Minimum value of L = M = N =            ', L_MIN
        write( stdout, '(a, i11)' ) '  Maximum value of L = M = N =            ', L_MAX
        write( stdout, '(a, i11)' ) '  Number of repetitions of the operation: ', REP_NUM

        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  Use nested do loops for matrix multiplication.'

        !
        !==> Perform naive calculation
        !
        do rep = 1, REP_NUM
            do l_log = L_LOG_MIN, L_LOG_MAX
                associate( l => 4**( l_log ) )

                    ! Allocate arrays
                    allocate( a(l,l) )
                    allocate( b(l,l) )
                    allocate( c(l,l) )

                    call random_number(harvest=a)
                    call random_number(harvest=b)

                    ! start timer
                    call timer%start()

                    do i = 1, l
                        do j = 1, l
                            c(i,j) = 0.0_wp
                            do k = 1, l
                                c(i,j) = c(i,j) + a(i,k) * b(k,j)
                            end do
                        end do
                    end do

                    ! stop timer
                    call timer%stop()

                    ! Get CPU time
                    delta(l_log, rep) = timer%get_elapsed_time()

                    ! Release memory
                    deallocate( a )
                    deallocate( b )
                    deallocate( c )

                end associate
            end do
        end do

        !
        !==> Print naive results
        !
        write( stdout, '(a)' ) ''
        write( stdout, '(a)' ) '  Timing results using nested do loops:'
        write( stdout, '(a)' ) ''
        write( stdout, '(6A)' ) &
            '       Size    ',&
            'Rep #1         ', &
            'Rep #2         ',&
            'Rep #3         ',&
            'Rep #4         ',&
            'Rep #5         '
        write( stdout, '(a)' ) ''

        do l_log = L_LOG_MIN, L_LOG_MAX
            associate( l => 4**( l_log ) )
                write( stdout, '(i11,5(1pe15.5))' ) l, delta(l_log,:)
            end associate
        end do

        !
        !==> Perform optimized calculation
        !
        write( stdout, '(/a)' ) '  Use the matmul routine for matrix multiplication.'

        do rep = 1, REP_NUM
            do l_log = L_LOG_MIN, L_LOG_MAX
                associate( l => 4**(l_log) )

                    ! Allocate memory
                    allocate( a(l,l) )
                    allocate( b(l,l) )
                    allocate( c(l,l) )

                    ! Generate some random data
                    call random_number(harvest=a)
                    call random_number(harvest=b)

                    ! start timer
                    call timer%start()

                    c = matmul(a, b)

                    ! stop timer
                    call timer%stop()

                    ! Set CPU time
                    delta(l_log, rep) = timer%get_elapsed_time()

                    ! Release memory
                    deallocate( a )
                    deallocate( b )
                    deallocate( c )

                end associate
            end do
        end do

        !
        !==> Print optimized results
        !
        write( stdout, '(/a/)' ) '  Timing results using matmul:'
        write( stdout, '(6a/)' ) &
            '       Size    ',&
            'Rep #1         ', &
            'Rep #2         ',&
            'Rep #3         ',&
            'Rep #4         ',&
            'Rep #5         '

        do l_log = L_LOG_MIN, L_LOG_MAX
            associate( l => 4**( l_log ))
                write( stdout, '(i11,5(1pe15.5))' ) l, delta(l_log,:)
            end associate
        end do

    end subroutine time_matrix_multiplication_problem

end program test
